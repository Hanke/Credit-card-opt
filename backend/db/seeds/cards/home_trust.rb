effective_from = Date.new(2025, 1, 1)

Seeds::UpsertCreditCard.call(
  name: "Home Trust Preferred Visa",
  issuer: "Home Trust",
  network: "Visa",
  annual_fee_cents: 0,
  currency: "Cash Back",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "No fee. Flat 1% cash back on all purchases and no foreign transaction fee.",
  rules: [
    { category: "general", earning_rate: 1.0, notes: "Flat 1% on all purchases; no category bonuses." }
  ]
)
