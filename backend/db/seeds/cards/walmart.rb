effective_from = Date.new(2025, 1, 1)

Seeds::UpsertCreditCard.call(
  name: "Walmart Rewards Mastercard",
  issuer: "Walmart",
  network: "Mastercard",
  annual_fee_cents: 0,
  currency: "Walmart Reward Dollars",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "No fee. 1.25% back in Walmart Reward Dollars at Walmart stores and 3% at Walmart.ca (merchant " \
         "specific), 1% everywhere else.",
  rules: [
    { category: "general", earning_rate: 1.0,
      notes: "Flat 1% outside Walmart; Walmart store and Walmart.ca rates are merchant specific." }
  ]
)
