import { useId } from 'react'
import type { Recommendation } from '../../api'
import { Badge, Card, Icon, LinkButton } from '../../components/ui'
import { cn } from '../../components/ui/cn'
import { formatCentsExact, formatPoints, formatRate } from '../../lib/format'
import { RankBadge } from './RankBadge'

interface ComparisonTableProps {
  ranked: Recommendation[]
}

function deltaLabel(winner: Recommendation, runnerUp: Recommendation): string {
  const delta = winner.estimated_value_cents - runnerUp.estimated_value_cents
  return delta > 0 ? `+${formatCentsExact(delta)} vs next best` : 'Tied with next best'
}

export function ComparisonTable({ ranked }: ComparisonTableProps) {
  const headingId = useId()
  const [winner, runnerUp] = ranked

  return (
    <Card as="section" aria-labelledby={headingId} className="flex flex-col">
      <div className="mb-4 flex items-baseline justify-between gap-3">
        <h3 id={headingId} className="text-lg font-semibold tracking-tight text-slate-900">
          Every card, ranked
        </h3>
        {runnerUp !== undefined && <span className="text-sm text-slate-500">{ranked.length} cards compared</span>}
      </div>

      {runnerUp === undefined ? (
        <SingleCardNotice />
      ) : (
        <div className="-mx-5 overflow-x-auto sm:-mx-6">
          <table className="w-full border-collapse text-sm">
            <caption className="sr-only">Wallet cards ranked by estimated value for this purchase</caption>
            <thead>
              <tr className="text-left text-xs font-medium tracking-wide text-slate-400 uppercase">
                <th scope="col" className="py-2 pl-5 pr-3 font-medium sm:pl-6">
                  Card
                </th>
                <th scope="col" className="px-3 py-2 text-right font-medium">
                  Rate
                </th>
                <th scope="col" className="hidden px-3 py-2 text-right font-medium sm:table-cell">
                  Points
                </th>
                <th scope="col" className="py-2 pr-5 pl-3 text-right font-medium sm:pr-6">
                  Value
                </th>
              </tr>
            </thead>
            <tbody>
              {ranked.map((row, index) => (
                <ComparisonRow
                  key={row.credit_card_id}
                  row={row}
                  rank={index + 1}
                  best={index === 0}
                  delta={index === 0 ? deltaLabel(winner, runnerUp) : null}
                />
              ))}
            </tbody>
          </table>
        </div>
      )}
    </Card>
  )
}

interface ComparisonRowProps {
  row: Recommendation
  rank: number
  best: boolean
  delta: string | null
}

function ComparisonRow({ row, rank, best, delta }: ComparisonRowProps) {
  const points = row.cash_back ? null : formatPoints(row.points_earned)

  return (
    <tr className={cn('border-t border-slate-100 align-top', best && 'bg-brand-50/70')}>
      <th
        scope="row"
        className={cn(
          'py-3 pl-5 pr-3 text-left font-normal sm:pl-6',
          best && 'shadow-[inset_3px_0_0_0] shadow-brand-500',
        )}
      >
        <div className="flex items-start gap-3">
          <RankBadge rank={rank} highlighted={best} />
          <div className="min-w-0">
            <div className="flex flex-wrap items-center gap-2">
              <span className="font-semibold text-slate-900">{row.card_name}</span>
              {best && <Badge tone="brand">Best</Badge>}
            </div>
            <p className="mt-0.5 text-xs text-slate-500">
              {row.issuer} · {row.reward_currency}
            </p>
          </div>
        </div>
      </th>
      <td className="px-3 py-3 text-right whitespace-nowrap text-slate-700 tabular-nums">
        {formatRate(row.earning_rate, row.cash_back)}
        {points && <p className="mt-0.5 text-xs text-slate-500 sm:hidden">{points}</p>}
      </td>
      <td className="hidden px-3 py-3 text-right whitespace-nowrap text-slate-700 tabular-nums sm:table-cell">
        {points ?? <NotApplicable />}
      </td>
      <td className="py-3 pr-5 pl-3 text-right tabular-nums sm:pr-6">
        <span className={cn('font-semibold whitespace-nowrap', best ? 'text-brand-700' : 'text-slate-900')}>
          {formatCentsExact(row.estimated_value_cents)}
        </span>
        {delta && <p className="mt-0.5 ml-auto max-w-28 text-xs font-medium text-emerald-700 sm:max-w-none sm:whitespace-nowrap">{delta}</p>}
      </td>
    </tr>
  )
}

function NotApplicable() {
  return (
    <>
      <span aria-hidden="true">—</span>
      <span className="sr-only">Not applicable</span>
    </>
  )
}

function SingleCardNotice() {
  return (
    <div className="flex flex-col items-start gap-4 rounded-xl border border-dashed border-slate-200 bg-slate-50/60 p-5 sm:flex-row sm:items-center sm:justify-between">
      <div>
        <p className="font-medium text-slate-900">Nothing to compare yet</p>
        <p className="mt-1 text-sm leading-relaxed text-slate-500">
          This is the only card in your wallet. Add another and we will rank them side by side.
        </p>
      </div>
      <LinkButton to="/wallet" variant="secondary" size="sm" className="shrink-0">
        <Icon name="plus" className="size-4" />
        Add cards
      </LinkButton>
    </div>
  )
}
