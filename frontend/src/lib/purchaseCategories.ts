import { PURCHASE_CATEGORIES, type PurchaseCategory } from '../api'
import type { SelectOption } from '../components/ui'

export const PURCHASE_CATEGORY_LABELS: Record<PurchaseCategory, string> = {
  groceries: 'Groceries',
  dining: 'Dining',
  gas: 'Gas',
  travel: 'Travel',
  hotels: 'Hotels',
  flights: 'Flights',
  transit: 'Transit',
  entertainment: 'Entertainment',
  drugstore: 'Drugstore',
  general: 'General purchases',
  other: 'Other',
}

export const PURCHASE_CATEGORY_OPTIONS: SelectOption[] = PURCHASE_CATEGORIES.map((value) => ({
  value,
  label: PURCHASE_CATEGORY_LABELS[value],
}))

export function isPurchaseCategory(value: string | null | undefined): value is PurchaseCategory {
  return (PURCHASE_CATEGORIES as readonly string[]).includes(value ?? '')
}
