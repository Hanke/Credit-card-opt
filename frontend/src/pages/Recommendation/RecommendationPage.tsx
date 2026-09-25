import { useEffect, useMemo } from 'react'
import { useSearchParams } from 'react-router-dom'
import { PageHeader } from '../../components/layout/PageHeader'
import { PurchaseForm } from '../../components/purchase/PurchaseForm'
import { PurchaseFormSkeleton } from '../../components/purchase/PurchaseFormSkeleton'
import { toPurchaseErrors } from '../../components/purchase/purchaseErrors'
import {
  readPurchase,
  samePurchase,
  writePurchase,
  type PurchaseInput,
} from '../../components/purchase/purchaseSearchParams'
import { Card, EmptyState, Icon, LinkButton, LoadingRegion } from '../../components/ui'
import { WalletErrorAlert } from '../../components/wallet/WalletErrorAlert'
import { useDocumentTitle } from '../../hooks/useDocumentTitle'
import { useRecommendation } from '../../hooks/useRecommendation'
import { useWallet } from '../../hooks/useWallet'
import { RecommendationSection } from './RecommendationSection'

export function RecommendationPage() {
  useDocumentTitle('Recommend')
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
        <LoadingRegion label="Loading your wallet">
          <PurchaseFormSkeleton />
        </LoadingRegion>
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
          <RecommendationSection input={lastInput} data={data} loading={loading} />
        </>
      )}
    </>
  )
}
