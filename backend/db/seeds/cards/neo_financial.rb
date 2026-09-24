effective_from = Date.new(2025, 1, 1)

Seeds::UpsertCreditCard.call(
  name: "Neo World Elite Mastercard",
  issuer: "Neo Financial",
  network: "Mastercard",
  annual_fee_cents: 12_500,
  currency: "Cash Back",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "5% cash back on groceries, 4% on recurring bills, 3% on gas, 1% elsewhere, plus boosted cash " \
         "back at Neo partner merchants (merchant specific, not modelled). Rates assume the Neo Everyday " \
         "account bundle.",
  rules: [
    { category: "groceries", earning_rate: 5.0 },
    { category: "gas", earning_rate: 3.0 }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "Neo Mastercard",
  issuer: "Neo Financial",
  network: "Mastercard",
  annual_fee_cents: 0,
  currency: "Cash Back",
  base_earn_rate: 0.5,
  effective_from: effective_from,
  notes: "No fee. 0.5% cash back everywhere plus an average of 5% at thousands of Neo partner merchants " \
         "(merchant specific, not modelled as categories).",
  rules: [
    { category: "general", earning_rate: 0.5,
      notes: "Flat 0.5% outside the Neo partner network; partner offers are merchant specific." }
  ]
)
