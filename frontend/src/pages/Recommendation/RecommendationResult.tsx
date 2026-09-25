import type { Recommendation } from '../../api'
import { Badge, HeroCard, Icon } from '../../components/ui'
import { formatCentsExact, formatPoints, formatRate } from '../../lib/format'

const TRANSLUCENT_BADGE = 'bg-white/15 text-white ring-white/25'

interface RecommendationResultProps {
  recommendation: Recommendation
}

export function RecommendationResult({ recommendation }: RecommendationResultProps) {
  const rate = formatRate(recommendation.earning_rate, recommendation.cash_back)

  return (
    <HeroCard as="article" aria-label={`Best card: ${recommendation.card_name}`}>
      <div className="flex flex-col gap-6 sm:flex-row sm:items-end sm:justify-between">
        <div className="min-w-0">
          <p className="flex items-center gap-1.5 text-sm font-medium text-white/75">
            <Icon name="sparkles" className="size-4" />
            Use this card
          </p>
          <h3 className="mt-1.5 text-2xl font-semibold tracking-tight text-balance sm:text-3xl">
            {recommendation.card_name}
          </h3>
          <div className="mt-3 flex flex-wrap gap-1.5">
            <Badge className={TRANSLUCENT_BADGE}>{recommendation.issuer}</Badge>
            <Badge className={TRANSLUCENT_BADGE}>{recommendation.reward_currency}</Badge>
            <Badge className="bg-white text-brand-700 ring-white">{rate}</Badge>
          </div>
        </div>

        <div className="shrink-0 sm:text-right">
          <p className="text-sm font-medium text-white/75">Estimated value</p>
          <p className="mt-0.5 text-5xl font-semibold tracking-tight tabular-nums">
            {formatCentsExact(recommendation.estimated_value_cents)}
          </p>
          <p className="mt-1.5 text-sm text-white/80">
            {recommendation.cash_back
              ? `${rate} cash back · ${recommendation.rule_applied}`
              : `${formatPoints(recommendation.points_earned)} · ${recommendation.rule_applied}`}
          </p>
        </div>
      </div>
    </HeroCard>
  )
}
