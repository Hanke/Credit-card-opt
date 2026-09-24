import { apiDelete, apiGet, apiPost } from './client'
import type { WalletCard } from './types'

export async function getWallet(): Promise<WalletCard[]> {
  const { cards } = await apiGet<{ cards: WalletCard[] }>('/api/v1/wallet')
  return cards
}

export async function addToWallet(creditCardId: number): Promise<WalletCard> {
  const { card } = await apiPost<{ card: WalletCard }>('/api/v1/wallet', { credit_card_id: creditCardId })
  return card
}

export function removeFromWallet(creditCardId: number): Promise<void> {
  return apiDelete(`/api/v1/wallet/${creditCardId}`)
}
