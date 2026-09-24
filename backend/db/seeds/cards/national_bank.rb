effective_from = Date.new(2025, 1, 1)

Seeds::UpsertCreditCard.call(
  name: "National Bank World Elite Mastercard",
  issuer: "National Bank",
  network: "Mastercard",
  annual_fee_cents: 15_000,
  currency: "A la carte Rewards",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "5 a la carte points per dollar on groceries and restaurants, 2 points on gas, EV charging, travel " \
         "and recurring bills, 1 point elsewhere. Lounge access and a $150 annual travel credit.",
  rules: [
    { category: "groceries", earning_rate: 5.0 },
    { category: "dining", earning_rate: 5.0 },
    { category: "gas", earning_rate: 2.0, notes: "2x on gas and EV charging." },
    { category: "travel", earning_rate: 2.0 }
  ]
)
