effective_from = Date.new(2025, 1, 1)

Seeds::UpsertCreditCard.call(
  name: "CIBC Aventura Visa Infinite",
  issuer: "CIBC",
  network: "Visa",
  annual_fee_cents: 13_900,
  currency: "CIBC Aventura",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "2 Aventura points per dollar on travel booked through the CIBC Rewards Centre, 1.5 points on gas, " \
         "EV charging, groceries and drugstores, 1 point elsewhere.",
  rules: [
    { category: "travel", earning_rate: 2.0,
      notes: "2x only for travel booked through the CIBC Rewards Centre; other travel earns 1x." },
    { category: "gas", earning_rate: 1.5, notes: "1.5x on gas and EV charging." },
    { category: "groceries", earning_rate: 1.5 },
    { category: "drugstore", earning_rate: 1.5 }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "CIBC Aventura Visa Infinite Privilege",
  issuer: "CIBC",
  network: "Visa",
  annual_fee_cents: 49_900,
  currency: "CIBC Aventura",
  base_earn_rate: 1.25,
  effective_from: effective_from,
  notes: "3 Aventura points per dollar on travel booked through the CIBC Rewards Centre, 2 points on gas, " \
         "EV charging, groceries and drugstores, 1.25 points elsewhere. Lounge access.",
  rules: [
    { category: "travel", earning_rate: 3.0,
      notes: "3x only for travel booked through the CIBC Rewards Centre; other travel earns 1.25x." },
    { category: "gas", earning_rate: 2.0, notes: "2x on gas and EV charging." },
    { category: "groceries", earning_rate: 2.0 },
    { category: "drugstore", earning_rate: 2.0 }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "CIBC Aventura Gold Visa",
  issuer: "CIBC",
  network: "Visa",
  annual_fee_cents: 13_900,
  currency: "CIBC Aventura",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "Same earn structure as the Visa Infinite with a lower income requirement: 2 points on CIBC " \
         "Rewards Centre travel, 1.5 points on gas, EV charging, groceries and drugstores, 1 point elsewhere.",
  rules: [
    { category: "travel", earning_rate: 2.0,
      notes: "2x only for travel booked through the CIBC Rewards Centre; other travel earns 1x." },
    { category: "gas", earning_rate: 1.5, notes: "1.5x on gas and EV charging." },
    { category: "groceries", earning_rate: 1.5 },
    { category: "drugstore", earning_rate: 1.5 }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "CIBC Aeroplan Visa Infinite",
  issuer: "CIBC",
  network: "Visa",
  annual_fee_cents: 13_900,
  currency: "Aeroplan",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "1.5 Aeroplan points per dollar on gas, EV charging, groceries and direct Air Canada purchases, " \
         "1 point elsewhere. First checked bag free on Air Canada.",
  rules: [
    { category: "gas", earning_rate: 1.5, notes: "1.5x on gas and EV charging." },
    { category: "groceries", earning_rate: 1.5 },
    { category: "flights", earning_rate: 1.5,
      notes: "1.5x applies to purchases made directly with Air Canada; other airlines earn 1x." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "CIBC Aeroplan Visa Infinite Privilege",
  issuer: "CIBC",
  network: "Visa",
  annual_fee_cents: 59_900,
  currency: "Aeroplan",
  base_earn_rate: 1.25,
  effective_from: effective_from,
  notes: "2 Aeroplan points per dollar on direct Air Canada purchases, 1.5 points on gas, EV charging, " \
         "groceries, dining and travel, 1.25 points elsewhere. Maple Leaf Lounge access.",
  rules: [
    { category: "flights", earning_rate: 2.0,
      notes: "2x applies to purchases made directly with Air Canada; other airlines earn 1.5x as travel." },
    { category: "gas", earning_rate: 1.5, notes: "1.5x on gas and EV charging." },
    { category: "groceries", earning_rate: 1.5 },
    { category: "dining", earning_rate: 1.5 },
    { category: "travel", earning_rate: 1.5 }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "CIBC Dividend Visa Infinite",
  issuer: "CIBC",
  network: "Visa",
  annual_fee_cents: 12_000,
  currency: "Cash Back",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "4% cash back on groceries, gas and EV charging, 2% on dining, transportation and recurring bill " \
         "payments, 1% elsewhere. The 4% and 2% tiers share a $20,000/year cap.",
  rules: [
    { category: "groceries", earning_rate: 4.0, spend_cap_cents: 2_000_000,
      notes: "4% shares a $20,000/year cap with the other bonus categories; 1% after the cap." },
    { category: "gas", earning_rate: 4.0, spend_cap_cents: 2_000_000,
      notes: "4% on gas and EV charging, sharing a $20,000/year cap with the other bonus categories." },
    { category: "dining", earning_rate: 2.0, spend_cap_cents: 2_000_000,
      notes: "2% shares a $20,000/year cap with the other bonus categories." },
    { category: "transit", earning_rate: 2.0, spend_cap_cents: 2_000_000,
      notes: "2% on transportation (transit, taxis, rideshare), sharing the $20,000/year cap." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "CIBC Dividend Platinum Visa",
  issuer: "CIBC",
  network: "Visa",
  annual_fee_cents: 9_900,
  currency: "Cash Back",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "3% cash back on groceries, gas and EV charging, 2% on dining, transportation and recurring bill " \
         "payments, 1% elsewhere.",
  rules: [
    { category: "groceries", earning_rate: 3.0 },
    { category: "gas", earning_rate: 3.0, notes: "3% on gas and EV charging." },
    { category: "dining", earning_rate: 2.0 },
    { category: "transit", earning_rate: 2.0, notes: "2% on transportation (transit, taxis, rideshare)." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "CIBC Dividend Visa",
  issuer: "CIBC",
  network: "Visa",
  annual_fee_cents: 0,
  currency: "Cash Back",
  base_earn_rate: 0.5,
  effective_from: effective_from,
  notes: "No fee. 2% cash back on groceries, 1% on gas, EV charging, dining, transportation and recurring " \
         "bill payments, 0.5% elsewhere.",
  rules: [
    { category: "groceries", earning_rate: 2.0 },
    { category: "gas", earning_rate: 1.0, notes: "1% on gas and EV charging." },
    { category: "dining", earning_rate: 1.0 },
    { category: "transit", earning_rate: 1.0, notes: "1% on transportation (transit, taxis, rideshare)." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "CIBC Costco Mastercard",
  issuer: "CIBC",
  network: "Mastercard",
  annual_fee_cents: 0,
  currency: "Cash Back",
  base_earn_rate: 0.5,
  effective_from: effective_from,
  notes: "No fee with a Costco membership. 3% cash back on restaurants and Costco.ca, 2% on gas and EV " \
         "charging including Costco Gas (first $8,000/year), 1% at Costco warehouses (merchant specific), " \
         "0.5% elsewhere.",
  rules: [
    { category: "dining", earning_rate: 3.0, notes: "3% on restaurants; Costco.ca also earns 3%." },
    { category: "gas", earning_rate: 2.0, spend_cap_cents: 800_000,
      notes: "2% on the first $8,000/year of gas and EV charging, including Costco Gas; 0.5% after the cap." }
  ]
)
