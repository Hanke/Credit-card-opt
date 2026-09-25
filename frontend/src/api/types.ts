export interface User {
  id: number
  email: string
  created_at: string
}

export interface Credentials {
  email: string
  password: string
}

export interface SessionResponse {
  token: string
  user: User
}

export interface HealthResponse {
  status: string
  time: string
}

export interface ApiErrorBody {
  errors: string[]
}

export const PURCHASE_CATEGORIES = [
  'groceries',
  'dining',
  'gas',
  'travel',
  'hotels',
  'flights',
  'transit',
  'entertainment',
  'drugstore',
  'general',
  'other',
] as const

export type PurchaseCategory = (typeof PURCHASE_CATEGORIES)[number]

export interface RewardCurrency {
  id: number
  name: string
  cents_per_point: string
  description: string | null
}

export type RewardCurrencySummary = Pick<RewardCurrency, 'id' | 'name'>

export interface RewardRule {
  id: number
  category: PurchaseCategory
  earning_rate: string
  spend_cap_cents: number | null
  effective_from: string
  effective_to: string | null
  notes: string | null
}

export interface CreditCard {
  id: number
  name: string
  issuer: string
  network: string | null
  annual_fee_cents: number
  base_earn_rate: string
  reward_currency: RewardCurrencySummary
}

export interface CreditCardDetail extends CreditCard {
  notes: string | null
  reward_currency: RewardCurrency
  reward_rules: RewardRule[]
}

export interface WalletCard extends CreditCard {
  active: boolean
  added_at: string
}

export interface RecommendationRequest {
  amount: number
  category: PurchaseCategory
  user_card_ids?: number[]
}

export interface Recommendation {
  credit_card_id: number
  card_name: string
  issuer: string
  reward_currency: string
  earning_rate: string
  points_earned: string
  estimated_value_cents: number
  rule_applied: string
  spend_cap_cents: number | null
  explanation: string
}

export interface RecommendationResponse {
  recommendation: Recommendation
  comparisons: Recommendation[]
  input: {
    amount: string
    category: PurchaseCategory
  }
}
