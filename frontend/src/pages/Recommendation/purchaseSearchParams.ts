import type { RecommendationRequest } from '../../api'
import { validateAmount } from '../../lib/amountInput'
import { isPurchaseCategory } from '../../lib/purchaseCategories'

export type PurchaseInput = Pick<RecommendationRequest, 'amount' | 'category'>

export function readPurchase(params: URLSearchParams): PurchaseInput | null {
  const { amount } = validateAmount(params.get('amount') ?? '')
  const category = params.get('category')
  if (amount === null || !isPurchaseCategory(category)) return null
  return { amount, category }
}

export function writePurchase(input: PurchaseInput): Record<string, string> {
  return { amount: String(input.amount), category: input.category }
}

export function samePurchase(a: PurchaseInput | null, b: PurchaseInput | null): boolean {
  return a !== null && b !== null && a.amount === b.amount && a.category === b.category
}
