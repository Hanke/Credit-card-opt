import type { RecommendationRequest, RecommendationResponse } from '../../api'
import { Card, SectionHeading, Skeleton } from '../../components/ui'
import { formatDollars } from '../../lib/format'
import { PURCHASE_CATEGORY_LABELS } from '../../lib/purchaseCategories'
import { ComparisonTable } from './ComparisonTable'
import { ExplanationPanel } from './ExplanationPanel'
import { RecommendationResult } from './RecommendationResult'

interface RecommendationSectionProps {
  input: RecommendationRequest | null
  data: RecommendationResponse | null
  loading: boolean
}

export function RecommendationSection({ input, data, loading }: RecommendationSectionProps) {
  if (!input || (!loading && !data)) return null

  return (
    <section aria-label="Recommendation" aria-busy={loading || undefined} className="mt-8">
      <SectionHeading className="mb-4">
        Best card for {formatDollars(input.amount)} on {PURCHASE_CATEGORY_LABELS[input.category]}
      </SectionHeading>
      {loading || !data ? <ResultSkeleton /> : <Results data={data} />}
    </section>
  )
}

function Results({ data }: { data: RecommendationResponse }) {
  const ranked = [data.recommendation, ...data.comparisons]

  return (
    <div className="flex flex-col gap-4">
      <RecommendationResult recommendation={data.recommendation} />
      <div className="grid gap-4 lg:grid-cols-5">
        <div className="min-w-0 lg:col-span-3">
          <ComparisonTable ranked={ranked} />
        </div>
        <div className="min-w-0 lg:col-span-2">
          <ExplanationPanel ranked={ranked} />
        </div>
      </div>
    </div>
  )
}

function ResultSkeleton() {
  return (
    <div className="flex flex-col gap-4">
      <Card>
        <div className="flex flex-col gap-6 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <Skeleton className="h-4 w-24" />
            <Skeleton className="mt-3 h-8 w-56" />
            <div className="mt-3 flex gap-1.5">
              <Skeleton className="h-5 w-24 rounded-full" />
              <Skeleton className="h-5 w-32 rounded-full" />
              <Skeleton className="h-5 w-10 rounded-full" />
            </div>
          </div>
          <div className="sm:text-right">
            <Skeleton className="h-4 w-28 sm:ml-auto" />
            <Skeleton className="mt-2 h-12 w-32 sm:ml-auto" />
            <Skeleton className="mt-2 h-4 w-40 sm:ml-auto" />
          </div>
        </div>
      </Card>
      <div className="grid gap-4 lg:grid-cols-5">
        <Card className="lg:col-span-3">
          <Skeleton className="h-6 w-40" />
          <Skeleton className="mt-5 h-10" />
          <Skeleton className="mt-2 h-10" />
          <Skeleton className="mt-2 h-10" />
        </Card>
        <Card className="lg:col-span-2">
          <Skeleton className="h-6 w-32" />
          <Skeleton className="mt-5 h-20" />
        </Card>
      </div>
    </div>
  )
}
