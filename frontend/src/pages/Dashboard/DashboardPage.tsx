import { useRef } from 'react'
import { PageHeader } from '../../components/layout/PageHeader'
import { PurchaseFormSkeleton } from '../../components/purchase/PurchaseFormSkeleton'
import { Button, Icon, LoadingRegion } from '../../components/ui'
import { WalletErrorAlert } from '../../components/wallet/WalletErrorAlert'
import { WalletSkeleton } from '../../components/wallet/WalletSkeleton'
import { useAuth } from '../../hooks/useAuth'
import { useDisclosure } from '../../hooks/useDisclosure'
import { useDocumentTitle } from '../../hooks/useDocumentTitle'
import { useWallet } from '../../hooks/useWallet'
import { formatCardCount } from '../../lib/format'
import { CardSearchModal } from '../Wallet/CardSearchModal'
import { Onboarding } from './Onboarding'
import { QuickCheck } from './QuickCheck'
import { WalletSummary } from './WalletSummary'

function headerDescription(count: number): string {
  if (count === 0) return 'Set up your wallet to get started.'
  return `${formatCardCount(count)} in your wallet. Check a purchase to see which one to use.`
}

export function DashboardPage() {
  useDocumentTitle('Dashboard')
  const { user } = useAuth()
  const wallet = useWallet()
  const search = useDisclosure()
  const addCardsButton = useRef<HTMLButtonElement>(null)
  const ready = !wallet.loading && !wallet.error
  const empty = ready && wallet.cards.length === 0

  return (
    <>
      <PageHeader
        eyebrow={user ? `Signed in as ${user.email}` : undefined}
        title="Dashboard"
        description={ready ? headerDescription(wallet.cards.length) : 'Overview of your cards and rewards.'}
        actions={
          ready &&
          !empty && (
            <Button ref={addCardsButton} variant="secondary" onClick={search.show}>
              <Icon name="plus" className="size-4" />
              Add cards
            </Button>
          )
        }
      />

      {wallet.error && !wallet.loading && <WalletErrorAlert onRetry={wallet.reload} />}

      {wallet.loading ? (
        <LoadingRegion label="Loading your wallet">
          <PurchaseFormSkeleton />
          <WalletSkeleton className="mt-8" />
        </LoadingRegion>
      ) : empty ? (
        <Onboarding onAddCard={search.show} />
      ) : (
        ready && (
          <>
            <QuickCheck />
            <WalletSummary cards={wallet.cards} />
          </>
        )
      )}

      <CardSearchModal
        open={search.open}
        onClose={search.hide}
        fallbackFocus={addCardsButton}
        inWallet={wallet.has}
        onAdd={wallet.add}
      />
    </>
  )
}
