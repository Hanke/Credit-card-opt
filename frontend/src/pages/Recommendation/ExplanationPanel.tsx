import { useId } from 'react'
import type { Recommendation } from '../../api'
import { Card, Icon } from '../../components/ui'
import { formatCentsExact } from '../../lib/format'
import { RankBadge } from './RankBadge'

interface ExplanationPanelProps {
  ranked: Recommendation[]
}

export function ExplanationPanel({ ranked }: ExplanationPanelProps) {
  const headingId = useId()
  const [winner, ...others] = ranked

  return (
    <Card as="section" aria-labelledby={headingId} className="flex flex-col">
      <h3 id={headingId} className="text-lg font-semibold tracking-tight text-slate-900">
        Why this card
      </h3>

      <div className="mt-4 flex gap-3 rounded-xl bg-brand-50 p-4 ring-1 ring-brand-100 ring-inset">
        <span className="flex size-8 shrink-0 items-center justify-center rounded-full bg-brand-600 text-white">
          <Icon name="check" className="size-4" />
        </span>
        <div className="min-w-0">
          <p className="font-semibold text-slate-900">{winner.card_name}</p>
          <p className="mt-1 text-sm leading-relaxed text-slate-700">{winner.explanation}</p>
        </div>
      </div>

      {others.length > 0 && (
        <details className="group mt-4">
          <summary className="flex cursor-pointer list-none items-center gap-1.5 text-sm font-medium text-brand-600 select-none hover:text-brand-700 [&::-webkit-details-marker]:hidden">
            <Icon name="arrow-right" className="size-4 transition-transform group-open:rotate-90" />
            See the math for every card
          </summary>
          <ol aria-label="Explanation for each card" className="mt-3 divide-y divide-slate-100">
            {ranked.map((row, index) => (
              <li key={row.credit_card_id} className="flex gap-3 py-3">
                <RankBadge rank={index + 1} />
                <div className="min-w-0 flex-1">
                  <div className="flex items-baseline justify-between gap-3">
                    <p className="font-medium text-slate-900">{row.card_name}</p>
                    <span className="shrink-0 text-sm font-semibold text-slate-700 tabular-nums">
                      {formatCentsExact(row.estimated_value_cents)}
                    </span>
                  </div>
                  <p className="mt-0.5 text-sm leading-relaxed text-slate-500">{row.explanation}</p>
                </div>
              </li>
            ))}
          </ol>
        </details>
      )}
    </Card>
  )
}
