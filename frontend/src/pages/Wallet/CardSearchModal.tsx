import { useEffect, useId, useRef, useState, type MouseEvent, type SyntheticEvent } from 'react'
import { isApiError, searchCards, type CreditCard } from '../../api'
import { CardBadges } from '../../components/cards/CardBadges'
import { Alert, Button, Icon, Spinner } from '../../components/ui'
import { controlClasses } from '../../components/ui/fieldHelpers'
import { useDebouncedValue } from '../../hooks/useDebouncedValue'
import { formatAnnualFee } from '../../lib/money'

const SEARCH_DEBOUNCE_MS = 300
const GENERIC_ERROR = 'Something went wrong. Please try again.'

type SearchOutcome = { query: string } & ({ status: 'ok'; cards: CreditCard[] } | { status: 'error' })

interface CardSearchModalProps {
  open: boolean
  onClose: () => void
  inWallet: (creditCardId: number) => boolean
  onAdd: (card: CreditCard) => Promise<unknown>
}

function errorMessage(error: unknown): string {
  return isApiError(error) && error.errors.length > 0 ? error.errors[0] : GENERIC_ERROR
}

export function CardSearchModal({ open, onClose, inWallet, onAdd }: CardSearchModalProps) {
  if (!open) return null
  return <CardSearchDialog onClose={onClose} inWallet={inWallet} onAdd={onAdd} />
}

function CardSearchDialog({ onClose, inWallet, onAdd }: Omit<CardSearchModalProps, 'open'>) {
  const titleId = useId()
  const dialogRef = useRef<HTMLDialogElement>(null)
  const inputRef = useRef<HTMLInputElement>(null)
  const [query, setQuery] = useState('')
  const debouncedQuery = useDebouncedValue(query.trim(), SEARCH_DEBOUNCE_MS)
  const [attempt, setAttempt] = useState(0)
  const [outcome, setOutcome] = useState<SearchOutcome | null>(null)
  const [addingId, setAddingId] = useState<number | null>(null)
  const [addError, setAddError] = useState<string | null>(null)
  const searching = outcome?.query !== debouncedQuery

  useEffect(() => {
    const dialog = dialogRef.current
    if (dialog && !dialog.open) dialog.showModal()
    inputRef.current?.focus()
  }, [])

  useEffect(() => {
    let cancelled = false
    searchCards(debouncedQuery || undefined)
      .then((cards) => {
        if (!cancelled) setOutcome({ status: 'ok', cards, query: debouncedQuery })
      })
      .catch(() => {
        if (!cancelled) setOutcome({ status: 'error', query: debouncedQuery })
      })
    return () => {
      cancelled = true
    }
  }, [debouncedQuery, attempt])

  function handleCancel(event: SyntheticEvent<HTMLDialogElement>) {
    if (!query) return
    event.preventDefault()
    setQuery('')
  }

  function handleBackdropClick(event: MouseEvent<HTMLDialogElement>) {
    if (event.target === event.currentTarget) event.currentTarget.close()
  }

  async function handleAdd(card: CreditCard) {
    setAddingId(card.id)
    setAddError(null)
    try {
      await onAdd(card)
    } catch (error) {
      setAddError(`Could not add ${card.name}. ${errorMessage(error)}`)
    } finally {
      setAddingId(null)
    }
  }

  return (
    <dialog
      ref={dialogRef}
      aria-labelledby={titleId}
      onCancel={handleCancel}
      onClose={onClose}
      onClick={handleBackdropClick}
      className="fixed inset-0 mx-auto mt-auto mb-0 max-h-[88svh] w-full max-w-2xl flex-col rounded-t-2xl bg-white p-0 text-slate-700 shadow-float backdrop:bg-slate-900/50 backdrop:backdrop-blur-sm open:flex sm:my-auto sm:max-h-[80vh] sm:w-[calc(100%-3rem)] sm:rounded-2xl"
    >
      <header className="flex items-center justify-between gap-4 border-b border-slate-100 px-5 py-4 sm:px-6">
        <h2 id={titleId} className="text-lg font-semibold tracking-tight text-slate-900">
          Add cards
        </h2>
        <Button
          variant="ghost"
          size="sm"
          onClick={() => dialogRef.current?.close()}
          aria-label="Close"
          className="-mr-2 px-2"
        >
          <Icon name="x" className="size-5" />
        </Button>
      </header>

      <div className="px-5 pt-4 sm:px-6">
        <div className="relative">
          <Icon name="search" className="pointer-events-none absolute top-1/2 left-3.5 size-4.5 -translate-y-1/2 text-slate-400" />
          <input
            ref={inputRef}
            type="search"
            aria-label="Search cards"
            placeholder="Search by card name or issuer"
            autoComplete="off"
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            className={controlClasses(undefined, 'pl-10')}
          />
          {searching && outcome && (
            <Spinner size="sm" label="Searching cards" className="absolute top-1/2 right-3.5 -translate-y-1/2" />
          )}
        </div>
        {addError && <Alert message={addError} className="mt-3 py-2.5" />}
      </div>

      <div aria-busy={searching || undefined} className="min-h-48 flex-1 overflow-y-auto px-5 py-4 sm:px-6">
        <SearchResults
          outcome={outcome}
          inWallet={inWallet}
          addingId={addingId}
          onAdd={handleAdd}
          onRetry={() => setAttempt((count) => count + 1)}
        />
      </div>
    </dialog>
  )
}

interface SearchResultsProps {
  outcome: SearchOutcome | null
  inWallet: (creditCardId: number) => boolean
  addingId: number | null
  onAdd: (card: CreditCard) => void
  onRetry: () => void
}

function SearchResults({ outcome, inWallet, addingId, onAdd, onRetry }: SearchResultsProps) {
  if (outcome === null) {
    return (
      <div className="flex h-40 items-center justify-center">
        <Spinner label="Searching cards" />
      </div>
    )
  }

  if (outcome.status === 'error') {
    return (
      <Alert
        message="Could not load cards. Check your connection and try again."
        action={
          <Button variant="secondary" size="sm" onClick={onRetry} className="-my-1.5">
            Retry
          </Button>
        }
      />
    )
  }

  if (outcome.cards.length === 0) {
    return (
      <div className="py-10 text-center">
        <p className="font-medium text-slate-900">No cards found</p>
        <p className="mt-1 text-sm text-slate-500">
          {outcome.query
            ? `Nothing matches “${outcome.query}”. Try a card name or issuer.`
            : 'There are no cards to add yet.'}
        </p>
      </div>
    )
  }

  return (
    <ul className="divide-y divide-slate-100">
      {outcome.cards.map((card) => (
        <SearchResultRow
          key={card.id}
          card={card}
          added={inWallet(card.id)}
          adding={addingId === card.id}
          disabled={addingId !== null}
          onAdd={() => onAdd(card)}
        />
      ))}
    </ul>
  )
}

interface SearchResultRowProps {
  card: CreditCard
  added: boolean
  adding: boolean
  disabled: boolean
  onAdd: () => void
}

function SearchResultRow({ card, added, adding, disabled, onAdd }: SearchResultRowProps) {
  return (
    <li className="flex items-center gap-3 py-3">
      <div className="min-w-0 flex-1">
        <p className="truncate font-medium text-slate-900">{card.name}</p>
        <div className="mt-1 flex flex-wrap items-center gap-1.5 text-xs text-slate-500">
          <CardBadges card={card} />
          <span>{formatAnnualFee(card.annual_fee_cents)}</span>
        </div>
      </div>
      {added ? (
        <Button variant="secondary" size="sm" disabled aria-label={`${card.name} already in wallet`}>
          <Icon name="check" className="size-4" />
          Added
        </Button>
      ) : (
        <Button size="sm" onClick={onAdd} loading={adding} disabled={disabled} aria-label={`Add ${card.name}`}>
          {!adding && <Icon name="plus" className="size-4" />}
          Add
        </Button>
      )}
    </li>
  )
}
