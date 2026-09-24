effective_from = Date.new(2025, 1, 1)

Seeds::UpsertCreditCard.call(
  name: "TD Aeroplan Visa Infinite",
  issuer: "TD",
  network: "Visa",
  annual_fee_cents: 13_900,
  currency: "Aeroplan",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "1.5x on gas, groceries and direct Air Canada purchases, 1x elsewhere. First checked bag free " \
         "on Air Canada.",
  rules: [
    { category: "gas", earning_rate: 1.5 },
    { category: "groceries", earning_rate: 1.5 },
    { category: "flights", earning_rate: 1.5,
      notes: "1.5x applies to purchases made directly with Air Canada; other airlines earn 1x." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "TD Aeroplan Visa Infinite Privilege",
  issuer: "TD",
  network: "Visa",
  annual_fee_cents: 59_900,
  currency: "Aeroplan",
  base_earn_rate: 1.25,
  effective_from: effective_from,
  notes: "2x on direct Air Canada purchases, 1.5x on gas, groceries, dining and travel, 1.25x elsewhere. " \
         "Maple Leaf Lounge access.",
  rules: [
    { category: "flights", earning_rate: 2.0,
      notes: "2x applies to purchases made directly with Air Canada; other airlines earn 1.5x as travel." },
    { category: "gas", earning_rate: 1.5 },
    { category: "groceries", earning_rate: 1.5 },
    { category: "dining", earning_rate: 1.5 },
    { category: "travel", earning_rate: 1.5 }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "TD First Class Travel Visa Infinite",
  issuer: "TD",
  network: "Visa",
  annual_fee_cents: 13_900,
  currency: "TD Rewards",
  base_earn_rate: 2.0,
  effective_from: effective_from,
  notes: "8 TD Rewards points per dollar on travel booked through Expedia For TD, 6 points on groceries, " \
         "restaurants and recurring bill payments, 2 points elsewhere.",
  rules: [
    { category: "travel", earning_rate: 8.0,
      notes: "8x only when booked through Expedia For TD; other travel earns 2x." },
    { category: "groceries", earning_rate: 6.0 },
    { category: "dining", earning_rate: 6.0, notes: "6x on restaurants and food delivery." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "TD Cash Back Visa Infinite",
  issuer: "TD",
  network: "Visa",
  annual_fee_cents: 13_900,
  currency: "Cash Back",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "3% cash back on groceries, gas and recurring bill payments up to $15,000/year combined, " \
         "1% on everything else. Recurring bills are not a purchase category here.",
  rules: [
    { category: "groceries", earning_rate: 3.0, spend_cap_cents: 1_500_000,
      notes: "3% shares a $15,000/year cap with gas and recurring bills; 1% after the cap." },
    { category: "gas", earning_rate: 3.0, spend_cap_cents: 1_500_000,
      notes: "3% shares a $15,000/year cap with groceries and recurring bills; 1% after the cap." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "TD Cash Back Visa",
  issuer: "TD",
  network: "Visa",
  annual_fee_cents: 0,
  currency: "Cash Back",
  base_earn_rate: 0.5,
  effective_from: effective_from,
  notes: "No fee. 1% cash back on groceries, gas and recurring bill payments, 0.5% on everything else.",
  rules: [
    { category: "groceries", earning_rate: 1.0 },
    { category: "gas", earning_rate: 1.0 }
  ]
)
