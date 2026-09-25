import { toFieldErrors, type FieldErrors } from '../../lib/fieldErrors'

const PURCHASE_FIELDS = ['amount', 'category'] as const

export type PurchaseErrors = FieldErrors<(typeof PURCHASE_FIELDS)[number]>

export function toPurchaseErrors(error: unknown): PurchaseErrors {
  return toFieldErrors(error, PURCHASE_FIELDS)
}
