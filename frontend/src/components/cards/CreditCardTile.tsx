import type { ReactNode } from 'react'
import type { CreditCard } from '../../api'
import { Card, Icon } from '../ui'
import { cn } from '../ui/cn'
import { formatAnnualFee, formatRate } from '../../lib/format'
import { CardBadges } from './CardBadges'

interface CreditCardTileProps {
  card: CreditCard
  footer?: ReactNode
  className?: string
}

export function CreditCardTile({ card, footer, className }: CreditCardTileProps) {
  return (
    <Card
      as="article"
      aria-label={card.name}
      className={cn('flex flex-col p-5 transition-colors hover:border-slate-300', className)}
    >
      <div className="flex items-start justify-between gap-3">
        <span className="flex size-10 shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-brand-500 to-violet-500 text-white shadow-sm">
          <Icon name="credit-card" className="size-5" />
        </span>
        <div className="flex flex-wrap justify-end gap-1.5">
          <CardBadges card={card} />
        </div>
      </div>

      <h3 className="mt-4 font-semibold tracking-tight text-slate-900">{card.name}</h3>

      <dl className="mt-3 grid grid-cols-2 gap-x-4 gap-y-2 text-sm">
        <div>
          <dt className="text-xs font-medium tracking-wide text-slate-400 uppercase">Annual fee</dt>
          <dd className="mt-0.5 text-slate-700">{formatAnnualFee(card.annual_fee_cents)}</dd>
        </div>
        <div>
          <dt className="text-xs font-medium tracking-wide text-slate-400 uppercase">Earns</dt>
          <dd className="mt-0.5 text-slate-700">
            {formatRate(card.base_earn_rate, card.reward_currency.cash_back)} {card.reward_currency.name}
          </dd>
        </div>
      </dl>

      {footer && <div className="mt-5 border-t border-slate-100 pt-4">{footer}</div>}
    </Card>
  )
}
