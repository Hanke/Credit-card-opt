import { useId } from 'react'
import type { WalletCard } from '../../api'
import { CreditCardTile } from '../../components/cards/CreditCardTile'
import { Icon, SectionHeading, TextLink } from '../../components/ui'
import { formatCardCount } from '../../lib/format'

const TILE_LIMIT = 3

interface WalletSummaryProps {
  cards: WalletCard[]
}

export function WalletSummary({ cards }: WalletSummaryProps) {
  const headingId = useId()
  const shown = cards.slice(0, TILE_LIMIT)

  return (
    <section aria-labelledby={headingId} className="mt-8">
      <div className="mb-4 flex items-baseline justify-between gap-3">
        <SectionHeading id={headingId}>Your wallet · {formatCardCount(cards.length)}</SectionHeading>
        <TextLink to="/wallet">
          Manage wallet
          <Icon name="arrow-right" className="size-4" />
        </TextLink>
      </div>
      <ul aria-label="Your cards" className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {shown.map((card) => (
          <li key={card.id}>
            <CreditCardTile card={card} />
          </li>
        ))}
      </ul>
      {cards.length > TILE_LIMIT && (
        <p className="mt-4 text-sm text-slate-500">
          Showing {shown.length} of {cards.length}.{' '}
          <TextLink to="/wallet">View all {formatCardCount(cards.length)}</TextLink>
        </p>
      )}
    </section>
  )
}
