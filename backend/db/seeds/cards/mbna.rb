effective_from = Date.new(2025, 1, 1)

Seeds::UpsertCreditCard.call(
  name: "MBNA Rewards World Elite Mastercard",
  issuer: "MBNA",
  network: "Mastercard",
  annual_fee_cents: 12_000,
  currency: "MBNA Rewards",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "5 MBNA Rewards points per dollar on groceries, restaurants, digital media, memberships and " \
         "household utilities (first $50,000/year combined), 1 point elsewhere. Annual birthday bonus.",
  rules: [
    { category: "groceries", earning_rate: 5.0, spend_cap_cents: 5_000_000,
      notes: "5x shares a $50,000/year cap across all bonus categories; 1x after the cap." },
    { category: "dining", earning_rate: 5.0, spend_cap_cents: 5_000_000,
      notes: "5x shares a $50,000/year cap across all bonus categories; 1x after the cap." },
    { category: "entertainment", earning_rate: 5.0, spend_cap_cents: 5_000_000,
      notes: "5x on digital media (streaming, apps, games), sharing the $50,000/year cap." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "MBNA Rewards Platinum Plus Mastercard",
  issuer: "MBNA",
  network: "Mastercard",
  annual_fee_cents: 0,
  currency: "MBNA Rewards",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "No fee. 2 MBNA Rewards points per dollar on groceries, restaurants, digital media, memberships " \
         "and household utilities (first $10,000/year combined), 1 point elsewhere.",
  rules: [
    { category: "groceries", earning_rate: 2.0, spend_cap_cents: 1_000_000,
      notes: "2x shares a $10,000/year cap across all bonus categories; 1x after the cap." },
    { category: "dining", earning_rate: 2.0, spend_cap_cents: 1_000_000,
      notes: "2x shares a $10,000/year cap across all bonus categories; 1x after the cap." },
    { category: "entertainment", earning_rate: 2.0, spend_cap_cents: 1_000_000,
      notes: "2x on digital media (streaming, apps, games), sharing the $10,000/year cap." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "MBNA Smart Cash Platinum Plus Mastercard",
  issuer: "MBNA",
  network: "Mastercard",
  annual_fee_cents: 0,
  currency: "Cash Back",
  base_earn_rate: 0.5,
  effective_from: effective_from,
  notes: "No fee. 2% cash back on gas and groceries (first $500/month combined), 0.5% elsewhere. " \
         "5% on gas and groceries for the first six months.",
  rules: [
    { category: "gas", earning_rate: 2.0, spend_cap_cents: 600_000,
      notes: "2% on the first $500/month ($6,000/year) of gas and groceries combined; 0.5% after the cap." },
    { category: "groceries", earning_rate: 2.0, spend_cap_cents: 600_000,
      notes: "2% on the first $500/month ($6,000/year) of gas and groceries combined; 0.5% after the cap." }
  ]
)
