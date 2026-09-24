effective_from = Date.new(2025, 1, 1)

Seeds::UpsertCreditCard.call(
  name: "Triangle World Elite Mastercard",
  issuer: "Canadian Tire",
  network: "Mastercard",
  annual_fee_cents: 0,
  currency: "Triangle Rewards",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "No fee. 4% in Canadian Tire Money at Canadian Tire, Sport Chek, Mark's and partner banners, " \
         "3% at grocery stores (first $12,000/year), 5 to 7 cents per litre at Canadian Tire Gas+, 1% elsewhere.",
  rules: [
    { category: "groceries", earning_rate: 3.0, spend_cap_cents: 1_200_000,
      notes: "3% on the first $12,000/year of groceries (excludes Costco and Walmart); 1% after the cap." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "Triangle Mastercard",
  issuer: "Canadian Tire",
  network: "Mastercard",
  annual_fee_cents: 0,
  currency: "Triangle Rewards",
  base_earn_rate: 0.5,
  effective_from: effective_from,
  notes: "No fee. 4% in Canadian Tire Money at Canadian Tire, Sport Chek, Mark's and partner banners, " \
         "1.5% at grocery stores (first $12,000/year), 5 cents per litre at Canadian Tire Gas+, 0.5% elsewhere.",
  rules: [
    { category: "groceries", earning_rate: 1.5, spend_cap_cents: 1_200_000,
      notes: "1.5% on the first $12,000/year of groceries (excludes Costco and Walmart); 0.5% after the cap." }
  ]
)
