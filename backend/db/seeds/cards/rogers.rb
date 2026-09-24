effective_from = Date.new(2025, 1, 1)

Seeds::UpsertCreditCard.call(
  name: "Rogers Red World Elite Mastercard",
  issuer: "Rogers Bank",
  network: "Mastercard",
  annual_fee_cents: 0,
  currency: "Cash Back",
  base_earn_rate: 1.5,
  effective_from: effective_from,
  notes: "No fee. 1.5% cash back on all purchases (2% for Rogers, Fido and Shaw customers who redeem " \
         "toward their bill) and 3% on U.S. dollar purchases, which is not a purchase category.",
  rules: [
    { category: "general", earning_rate: 1.5,
      notes: "Flat 1.5% on all purchases; 2% for Rogers, Fido and Shaw customers." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "Rogers Red Mastercard",
  issuer: "Rogers Bank",
  network: "Mastercard",
  annual_fee_cents: 0,
  currency: "Cash Back",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "No fee. 1% cash back on all purchases (1.5% for Rogers, Fido and Shaw customers) and 3% on " \
         "U.S. dollar purchases, which is not a purchase category.",
  rules: [
    { category: "general", earning_rate: 1.0,
      notes: "Flat 1% on all purchases; 1.5% for Rogers, Fido and Shaw customers." }
  ]
)
