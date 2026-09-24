import { useCallback, useEffect, useState } from 'react'
import { addToWallet, getWallet, removeFromWallet } from '../api'
import type { CreditCard, WalletCard } from '../api'

export interface UseWalletResult {
  cards: WalletCard[]
  loading: boolean
  error: Error | null
  has: (creditCardId: number) => boolean
  add: (card: CreditCard) => Promise<WalletCard>
  remove: (creditCardId: number) => Promise<void>
  reload: () => Promise<void>
}

function toOptimisticWalletCard(card: CreditCard): WalletCard {
  return { ...card, active: true, added_at: new Date().toISOString() }
}

function toError(error: unknown): Error {
  return error instanceof Error ? error : new Error(String(error))
}

function insertAt(cards: WalletCard[], index: number, card: WalletCard): WalletCard[] {
  const next = [...cards]
  next.splice(Math.min(index, next.length), 0, card)
  return next
}

export function useWallet(): UseWalletResult {
  const [cards, setCards] = useState<WalletCard[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const load = useCallback(
    () =>
      getWallet()
        .then((loaded) => {
          setCards(loaded)
          setError(null)
        })
        .catch((caught: unknown) => setError(toError(caught)))
        .finally(() => setLoading(false)),
    [],
  )

  const reload = useCallback(() => {
    setLoading(true)
    return load()
  }, [load])

  useEffect(() => {
    void load()
  }, [load])

  const has = useCallback((creditCardId: number) => cards.some((card) => card.id === creditCardId), [cards])

  const add = useCallback(
    async (card: CreditCard) => {
      const existing = cards.find((walletCard) => walletCard.id === card.id)
      if (existing) return existing

      const optimistic = toOptimisticWalletCard(card)
      setCards((current) => (current.some((walletCard) => walletCard.id === card.id) ? current : [...current, optimistic]))

      try {
        const saved = await addToWallet(card.id)
        setCards((current) => current.map((walletCard) => (walletCard.id === saved.id ? saved : walletCard)))
        return saved
      } catch (caught) {
        setCards((current) => current.filter((walletCard) => walletCard !== optimistic))
        throw caught
      }
    },
    [cards],
  )

  const remove = useCallback(
    async (creditCardId: number) => {
      const removedIndex = cards.findIndex((walletCard) => walletCard.id === creditCardId)
      if (removedIndex === -1) return
      const removed = cards[removedIndex]

      setCards((current) => current.filter((walletCard) => walletCard.id !== creditCardId))

      try {
        await removeFromWallet(creditCardId)
      } catch (caught) {
        setCards((current) =>
          current.some((walletCard) => walletCard.id === creditCardId)
            ? current
            : insertAt(current, removedIndex, removed),
        )
        throw caught
      }
    },
    [cards],
  )

  return { cards, loading, error, has, add, remove, reload }
}
