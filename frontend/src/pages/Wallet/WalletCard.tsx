import { useState } from 'react'
import type { WalletCard as WalletCardData } from '../../api'
import { CreditCardTile } from '../../components/cards/CreditCardTile'
import { Button, Icon } from '../../components/ui'

interface WalletCardProps {
  card: WalletCardData
  onRemove: (creditCardId: number) => Promise<void>
}

export function WalletCard({ card, onRemove }: WalletCardProps) {
  const [confirming, setConfirming] = useState(false)

  return (
    <CreditCardTile
      card={card}
      footer={
        confirming ? (
          <div className="flex items-center justify-between gap-3">
            <span className="text-sm text-slate-600">Remove this card?</span>
            <div className="flex gap-2">
              <Button variant="secondary" size="sm" onClick={() => setConfirming(false)}>
                Cancel
              </Button>
              <Button
                variant="danger"
                size="sm"
                onClick={() => void onRemove(card.id)}
                aria-label={`Confirm remove ${card.name}`}
              >
                Remove
              </Button>
            </div>
          </div>
        ) : (
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setConfirming(true)}
            aria-label={`Remove ${card.name}`}
            className="-ml-2 text-slate-500 hover:text-red-600"
          >
            <Icon name="trash" className="size-4" />
            Remove
          </Button>
        )
      }
    />
  )
}
