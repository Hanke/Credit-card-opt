export const MAX_AMOUNT = 1_000_000

const amountFormatter = new Intl.NumberFormat('en-CA', { minimumFractionDigits: 2, maximumFractionDigits: 2 })

export type AmountValidation = { amount: number; error: null } | { amount: null; error: string }

export function maskAmount(raw: string): string {
  const cleaned = raw.replace(/[^\d.]/g, '')
  const dotIndex = cleaned.indexOf('.')
  const integerDigits = (dotIndex === -1 ? cleaned : cleaned.slice(0, dotIndex)).replace(/^0+(?=\d)/, '')
  const decimals = dotIndex === -1 ? null : cleaned.slice(dotIndex + 1).replace(/\./g, '').slice(0, 2)
  const integerPart = integerDigits ? groupThousands(integerDigits) : decimals === null ? '' : '0'
  return decimals === null ? integerPart : `${integerPart}.${decimals}`
}

export function parseAmount(masked: string): number | null {
  const unmasked = masked.replace(/,/g, '')
  if (!/^(\d+\.?\d{0,2}|\.\d{1,2})$/.test(unmasked)) return null
  const amount = Number(unmasked)
  return amount > 0 ? amount : null
}

export function validateAmount(masked: string): AmountValidation {
  const amount = parseAmount(masked)
  if (amount === null) return { amount: null, error: 'Enter an amount greater than $0.' }
  if (amount > MAX_AMOUNT) return { amount: null, error: `Enter an amount of $${formatAmount(MAX_AMOUNT)} or less.` }
  return { amount, error: null }
}

export function formatAmount(amount: number): string {
  return amountFormatter.format(amount)
}

function groupThousands(digits: string): string {
  return digits.replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}
