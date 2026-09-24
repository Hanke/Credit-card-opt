import { useState } from 'react'
import { PageHeader } from '../../components/layout/PageHeader'
import { Alert, Button, Card, EmptyState, Icon, Skeleton, Toast } from '../../components/ui'
import { useToast } from '../../hooks/useToast'
import { useWallet } from '../../hooks/useWallet'
import { CardSearchModal } from './CardSearchModal'
import { WalletCard } from './WalletCard'

function countLabel(count: number): string {
  return count === 1 ? '1 card in your wallet' : `${count} cards in your wallet`
}

export function WalletPage() {
  const wallet = useWallet()
  const { toast, dismiss, showError } = useToast()
  const [searchOpen, setSearchOpen] = useState(false)
  const ready = !wallet.loading && !wallet.error

  async function handleRemove(creditCardId: number) {
    const card = wallet.cards.find((walletCard) => walletCard.id === creditCardId)
    try {
      await wallet.remove(creditCardId)
    } catch {
      showError(`Could not remove ${card?.name ?? 'that card'}. Please try again.`)
    }
  }

  const openSearch = () => setSearchOpen(true)
  const closeSearch = () => setSearchOpen(false)

  return (
    <>
      <PageHeader
        title="Wallet"
        description={ready ? countLabel(wallet.cards.length) : 'The cards you carry.'}
        actions={
          <Button onClick={openSearch} disabled={!ready}>
            <Icon name="plus" className="size-4" />
            Add cards
          </Button>
        }
      />

      {wallet.error && !wallet.loading && (
        <Alert
          message="Could not load your wallet."
          className="mb-6 items-center"
          action={
            <Button variant="secondary" size="sm" onClick={() => void wallet.reload()} className="-my-1.5">
              Retry
            </Button>
          }
        />
      )}

      {wallet.loading ? (
        <WalletSkeleton />
      ) : wallet.cards.length === 0 ? (
        !wallet.error && (
          <Card>
            <EmptyState
              icon="credit-card"
              title="No cards yet"
              description="Add the cards you carry and we will figure out which one to use for every purchase."
              action={
                <Button onClick={openSearch}>
                  <Icon name="plus" className="size-4" />
                  Add your first card
                </Button>
              }
            />
          </Card>
        )
      ) : (
        <ul aria-label="Your cards" className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {wallet.cards.map((card) => (
            <li key={card.id}>
              <WalletCard card={card} onRemove={handleRemove} />
            </li>
          ))}
        </ul>
      )}

      <CardSearchModal
        open={searchOpen}
        onClose={closeSearch}
        inWallet={wallet.has}
        onAdd={wallet.add}
      />

      {toast && <Toast message={toast.message} tone={toast.tone} onDismiss={dismiss} />}
    </>
  )
}

function WalletSkeleton() {
  return (
    <div role="status" aria-label="Loading your wallet" className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
      {Array.from({ length: 3 }, (_, index) => (
        <Card key={index} className="p-5">
          <div className="flex items-start justify-between">
            <Skeleton className="size-10 rounded-xl" />
            <Skeleton className="h-5 w-24 rounded-full" />
          </div>
          <Skeleton className="mt-4 h-5 w-3/4" />
          <div className="mt-4 grid grid-cols-2 gap-4">
            <Skeleton className="h-9" />
            <Skeleton className="h-9" />
          </div>
          <Skeleton className="mt-5 h-8 w-24" />
        </Card>
      ))}
    </div>
  )
}
