import { cn } from '../../components/ui/cn'

interface RankBadgeProps {
  rank: number
  highlighted?: boolean
}

export function RankBadge({ rank, highlighted = false }: RankBadgeProps) {
  return (
    <span
      className={cn(
        'mt-0.5 flex size-6 shrink-0 items-center justify-center rounded-full text-xs font-semibold tabular-nums',
        highlighted ? 'bg-brand-600 text-white' : 'bg-slate-100 text-slate-500',
      )}
    >
      {rank}
    </span>
  )
}
