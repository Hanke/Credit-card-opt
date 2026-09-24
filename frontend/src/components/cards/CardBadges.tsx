import type { CreditCard } from '../../api'
import { Badge } from '../ui'

export function CardBadges({ card }: { card: Pick<CreditCard, 'issuer' | 'network'> }) {
  return (
    <>
      <Badge tone="brand">{card.issuer}</Badge>
      {card.network && <Badge tone="neutral">{card.network}</Badge>}
    </>
  )
}
