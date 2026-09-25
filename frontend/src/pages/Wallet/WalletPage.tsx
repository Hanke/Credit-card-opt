import { useRef } from 'react'
import { PageHeader } from '../../components/layout/PageHeader'
import { Button, Card, EmptyState, Icon, LoadingRegion, Toast } from '../../components/ui'
import { WalletErrorAlert } from '../../components/wallet/WalletErrorAlert'
import { WalletSkeleton } from '../../components/wallet/WalletSkeleton'
import { useDisclosure } from '../../hooks/useDisclosure'
import { useDocumentTitle } from '../../hooks/useDocumentTitle'
import { useToast } from '../../hooks/useToast'
import { useWallet } from '../../hooks/useWallet'
import { formatCardCount } from '../../lib/format'
import { CardSearchModal } from './CardSearchModal'
import { WalletCard } from './WalletCard'

export function WalletPage() {
  useDocumentTitle('Wallet')
  const wallet = useWallet()
  const { toast, dismiss, showError } = useToast()
  const search = useDisclosure()
  const addCardsButton = useRef<HTMLButtonElement>(null)
  const ready = !wallet.loading && !wallet.error

  async function handleRemove(creditCardId: number) {
    const card = wallet.cards.find((walletCard) => walletCard.id === creditCardId)
    try {
      await wallet.remove(creditCardId)
    } catch {
      showError(`Could not remove ${card?.name ?? 'that card'}. Please try again.`)
    }
  }

  return (
    <>
      <PageHeader
        title="Wallet"
        description={ready ? `${formatCardCount(wallet.cards.length)} in your wallet` : 'The cards you carry.'}
        actions={
          <Button ref={addCardsButton} onClick={search.show} disabled={!ready}>
            <Icon name="plus" className="size-4" />
            Add cards
          </Button>
        }
      />

      {wallet.error && !wallet.loading && <WalletErrorAlert onRetry={wallet.reload} />}

      {wallet.loading ? (
        <LoadingRegion label="Loading your wallet">
          <WalletSkeleton />
        </LoadingRegion>
      ) : wallet.cards.length === 0 ? (
        !wallet.error && (
          <Card>
            <EmptyState
              icon="credit-card"
              title="No cards yet"
              description="Add the cards you carry and we will figure out which one to use for every purchase."
              action={
                <Button onClick={search.show}>
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
        open={search.open}
        onClose={search.hide}
        fallbackFocus={addCardsButton}
        inWallet={wallet.has}
        onAdd={wallet.add}
      />

      {toast && <Toast message={toast.message} tone={toast.tone} onDismiss={dismiss} />}
    </>
  )
}
