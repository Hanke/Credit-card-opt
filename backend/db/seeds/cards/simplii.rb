effective_from = Date.new(2025, 1, 1)

Seeds::UpsertCreditCard.call(
  name: "Simplii Financial Cash Back Visa",
  issuer: "Simplii Financial",
  network: "Visa",
  annual_fee_cents: 0,
  currency: "Cash Back",
  base_earn_rate: 0.5,
  effective_from: effective_from,
  notes: "No fee. 4% cash back on restaurants, bars and coffee shops (first $5,000/year), 1.5% on gas, " \
         "groceries, drugstores and recurring bills (first $15,000/year combined), 0.5% elsewhere.",
  rules: [
    { category: "dining", earning_rate: 4.0, spend_cap_cents: 500_000,
      notes: "4% on the first $5,000/year at restaurants, bars and coffee shops; 0.5% after the cap." },
    { category: "gas", earning_rate: 1.5, spend_cap_cents: 1_500_000,
      notes: "1.5% shares a $15,000/year cap with groceries, drugstores and recurring bills." },
    { category: "groceries", earning_rate: 1.5, spend_cap_cents: 1_500_000,
      notes: "1.5% shares a $15,000/year cap with gas, drugstores and recurring bills." },
    { category: "drugstore", earning_rate: 1.5, spend_cap_cents: 1_500_000,
      notes: "1.5% shares a $15,000/year cap with gas, groceries and recurring bills." }
  ]
)
