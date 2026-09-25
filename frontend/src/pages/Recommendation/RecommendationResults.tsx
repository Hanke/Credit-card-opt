import type { RecommendationRequest, RecommendationResponse } from '../../api'
import { Card, Skeleton } from '../../components/ui'
import { formatDollars } from '../../lib/money'
import { PURCHASE_CATEGORY_LABELS } from '../../lib/purchaseCategories'

interface RecommendationResultsProps {
  input: RecommendationRequest | null
  data: RecommendationResponse | null
  loading: boolean
}

export function RecommendationResults({ input, data, loading }: RecommendationResultsProps) {
  if (!input || (!loading && !data)) return null

  return (
    <section aria-label="Recommendation" aria-busy={loading || undefined} className="mt-8">
      <h2 className="mb-4 text-sm font-semibold tracking-wide text-slate-500 uppercase">
        Best card for {formatDollars(input.amount)} on {PURCHASE_CATEGORY_LABELS[input.category]}
      </h2>
      {loading || !data ? (
        <Card>
          <Skeleton className="h-6 w-1/3" />
          <Skeleton className="mt-3 h-4 w-2/3" />
        </Card>
      ) : (
        <Card as="article" aria-label={data.recommendation.card_name}>
          <p className="text-lg font-semibold tracking-tight text-slate-900">Use {data.recommendation.card_name}</p>
          <p className="mt-1.5 text-sm leading-relaxed text-slate-500">{data.recommendation.explanation}</p>
        </Card>
      )}
    </section>
  )
}
