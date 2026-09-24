effective_from = Date.new(2025, 1, 1)

Seeds::UpsertCreditCard.call(
  name: "BMO CashBack World Elite Mastercard",
  issuer: "BMO",
  network: "Mastercard",
  annual_fee_cents: 12_000,
  currency: "Cash Back",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "5% cash back on groceries (up to $500/month), 4% on transit (up to $300/month), 3% on gas and " \
         "EV charging (up to $300/month), 2% on recurring bills (up to $500/month), 1% elsewhere.",
  rules: [
    { category: "groceries", earning_rate: 5.0, spend_cap_cents: 600_000,
      notes: "5% on the first $500/month ($6,000/year) of groceries; 1% after the cap." },
    { category: "transit", earning_rate: 4.0, spend_cap_cents: 360_000,
      notes: "4% on the first $300/month ($3,600/year) of transit; 1% after the cap." },
    { category: "gas", earning_rate: 3.0, spend_cap_cents: 360_000,
      notes: "3% on the first $300/month ($3,600/year) of gas and EV charging; 1% after the cap." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "BMO CashBack Mastercard",
  issuer: "BMO",
  network: "Mastercard",
  annual_fee_cents: 0,
  currency: "Cash Back",
  base_earn_rate: 0.5,
  effective_from: effective_from,
  notes: "No fee. 3% cash back on groceries (up to $500/month), 1% on recurring bills, 0.5% elsewhere.",
  rules: [
    { category: "groceries", earning_rate: 3.0, spend_cap_cents: 600_000,
      notes: "3% on the first $500/month ($6,000/year) of groceries; 0.5% after the cap." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "BMO eclipse Visa Infinite",
  issuer: "BMO",
  network: "Visa",
  annual_fee_cents: 12_000,
  currency: "BMO Rewards",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "5 BMO Rewards points per dollar on groceries, dining, gas and transit on the first $50,000/year " \
         "combined, 1 point elsewhere. $50 annual lifestyle credit.",
  rules: [
    { category: "groceries", earning_rate: 5.0, spend_cap_cents: 5_000_000,
      notes: "5x shares a $50,000/year cap across groceries, dining, gas and transit." },
    { category: "dining", earning_rate: 5.0, spend_cap_cents: 5_000_000,
      notes: "5x shares a $50,000/year cap across groceries, dining, gas and transit." },
    { category: "gas", earning_rate: 5.0, spend_cap_cents: 5_000_000,
      notes: "5x shares a $50,000/year cap across groceries, dining, gas and transit." },
    { category: "transit", earning_rate: 5.0, spend_cap_cents: 5_000_000,
      notes: "5x shares a $50,000/year cap across groceries, dining, gas and transit." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "BMO eclipse Visa Infinite Privilege",
  issuer: "BMO",
  network: "Visa",
  annual_fee_cents: 49_900,
  currency: "BMO Rewards",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "5 BMO Rewards points per dollar on groceries, dining, drugstores, gas and travel, 1 point " \
         "elsewhere. $200 annual lifestyle credit and lounge access.",
  rules: [
    { category: "groceries", earning_rate: 5.0 },
    { category: "dining", earning_rate: 5.0 },
    { category: "drugstore", earning_rate: 5.0 },
    { category: "gas", earning_rate: 5.0 },
    { category: "travel", earning_rate: 5.0 }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "BMO eclipse rise Visa",
  issuer: "BMO",
  network: "Visa",
  annual_fee_cents: 0,
  currency: "BMO Rewards",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "No fee. 5 BMO Rewards points per dollar on dining and takeout, 4 points on recurring bills, " \
         "1 point elsewhere.",
  rules: [
    { category: "dining", earning_rate: 5.0, notes: "5x on restaurants, takeout and food delivery." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "BMO Ascend World Elite Mastercard",
  issuer: "BMO",
  network: "Mastercard",
  annual_fee_cents: 15_000,
  currency: "BMO Rewards",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "5 BMO Rewards points per dollar on travel, 3 points on dining and entertainment, 2 points on " \
         "recurring bills, 1 point elsewhere. Lounge membership and travel insurance.",
  rules: [
    { category: "travel", earning_rate: 5.0 },
    { category: "flights", earning_rate: 5.0, notes: "Flights are part of the 5x travel tier." },
    { category: "hotels", earning_rate: 5.0, notes: "Hotels are part of the 5x travel tier." },
    { category: "dining", earning_rate: 3.0 },
    { category: "entertainment", earning_rate: 3.0 }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "BMO Air Miles World Elite Mastercard",
  issuer: "BMO",
  network: "Mastercard",
  annual_fee_cents: 12_000,
  currency: "Air Miles",
  base_earn_rate: 0.0833,
  effective_from: effective_from,
  notes: "1 Mile per $12 (0.0833 miles per dollar) on all purchases, 2 Miles per $12 at grocery stores, " \
         "and 3 Miles per $12 (0.25 per dollar) at participating Air Miles partners, which are merchant " \
         "specific and not modelled as a category.",
  rules: [
    { category: "groceries", earning_rate: 0.1667,
      notes: "2 Miles per $12 at eligible grocery stores; Air Miles partner grocers earn 3 per $12." }
  ]
)
