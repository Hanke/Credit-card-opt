const CURRENCY = { style: 'currency', currency: 'CAD' } as const

const wholeDollars = new Intl.NumberFormat('en-CA', { ...CURRENCY, minimumFractionDigits: 0, maximumFractionDigits: 0 })
const dollarsAndCents = new Intl.NumberFormat('en-CA', { ...CURRENCY, minimumFractionDigits: 2, maximumFractionDigits: 2 })
const plainNumber = new Intl.NumberFormat('en-CA', { maximumFractionDigits: 2 })

export function formatCents(cents: number): string {
  return (cents % 100 === 0 ? wholeDollars : dollarsAndCents).format(cents / 100)
}

export function formatCentsExact(cents: number): string {
  return dollarsAndCents.format(cents / 100)
}

export function formatDollars(amount: number): string {
  return formatCents(Math.round(amount * 100))
}

export function formatAnnualFee(cents: number): string {
  return cents === 0 ? 'No annual fee' : `${formatCents(cents)}/yr`
}

export function formatRate(rate: string | number, cashBack: boolean): string {
  const value = plainNumber.format(Number(rate))
  return cashBack ? `${value}%` : `${value}x`
}

export function formatPoints(points: string | number): string {
  return `${plainNumber.format(Number(points))} pts`
}
