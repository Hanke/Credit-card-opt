import { useEffect, useMemo } from 'react'
import { useSearchParams } from 'react-router-dom'
import { PageHeader } from '../../components/layout/PageHeader'
import { Card, EmptyState, Icon, LinkButton, Skeleton } from '../../components/ui'
import { WalletErrorAlert } from '../../components/wallet/WalletErrorAlert'
import { useRecommendation } from '../../hooks/useRecommendation'
import { useWallet } from '../../hooks/useWallet'
import { PurchaseForm } from './PurchaseForm'
import { toPurchaseErrors } from './purchaseErrors'
import { RecommendationResults } from './RecommendationResults'
import { readPurchase, samePurchase, writePurchase, type PurchaseInput } from './purchaseSearchParams'

export function RecommendationPage() {
  const wallet = useWallet()
  const [searchParams, setSearchParams] = useSearchParams()
  const purchase = useMemo(() => readPurchase(searchParams), [searchParams])
  const { data, loading, error, lastInput, recommend } = useRecommendation()
  const hasCards = !wallet.loading && wallet.cards.length > 0
  const errors = error ? toPurchaseErrors(error) : {}

  useEffect(() => {
    if (!purchase || !hasCards || samePurchase(purchase, lastInput)) return
    void recommend(purchase)
  }, [purchase, hasCards, lastInput, recommend])

  function handleSubmit(input: PurchaseInput) {
    void recommend(input)
    setSearchParams(writePurchase(input), { replace: true })
  }

  return (
    <>
      <PageHeader title="Recommend" description="Find the best card for a purchase." />

      {wallet.error && !wallet.loading && <WalletErrorAlert onRetry={wallet.reload} />}

      {wallet.loading ? (
        <FormSkeleton />
      ) : wallet.cards.length === 0 ? (
        !wallet.error && (
          <Card>
            <EmptyState
              icon="sparkles"
              title="Which card should you use?"
              description="Once your wallet has cards, tell us what you are buying and we will pick the card with the best rewards."
              action={
                <LinkButton to="/wallet" variant="secondary">
                  <Icon name="wallet" className="size-4" />
                  Set up your wallet
                </LinkButton>
              }
            />
          </Card>
        )
      ) : (
        <>
          <Card title="What are you buying?" description="Enter the amount and pick a category.">
            <PurchaseForm initial={purchase} submitting={loading} errors={errors} onSubmit={handleSubmit} />
          </Card>
          <RecommendationResults input={lastInput} data={data} loading={loading} />
        </>
      )}
    </>
  )
}

function FormSkeleton() {
  return (
    <Card role="status" aria-label="Loading your wallet">
      <Skeleton className="h-6 w-48" />
      <Skeleton className="mt-2 h-4 w-64" />
      <div className="mt-6 grid gap-4 sm:grid-cols-[1fr_1fr_auto]">
        <Skeleton className="h-11" />
        <Skeleton className="h-11" />
        <Skeleton className="h-11 w-44" />
      </div>
    </Card>
  )
}
