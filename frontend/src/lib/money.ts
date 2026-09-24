const currencyFormatter = new Intl.NumberFormat('en-CA', {
  style: 'currency',
  currency: 'CAD',
  minimumFractionDigits: 0,
  maximumFractionDigits: 2,
})

export function formatCents(cents: number): string {
  return currencyFormatter.format(cents / 100)
}

export function formatAnnualFee(cents: number): string {
  return cents === 0 ? 'No annual fee' : `${formatCents(cents)}/yr`
}
