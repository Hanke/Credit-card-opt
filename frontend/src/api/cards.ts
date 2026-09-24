import { apiGet, withQuery } from './client'
import type { CreditCard, CreditCardDetail } from './types'

export async function searchCards(q?: string): Promise<CreditCard[]> {
  const { cards } = await apiGet<{ cards: CreditCard[] }>(withQuery('/api/v1/cards', { q }))
  return cards
}

export async function getCard(id: number): Promise<CreditCardDetail> {
  const { card } = await apiGet<{ card: CreditCardDetail }>(`/api/v1/cards/${id}`)
  return card
}
