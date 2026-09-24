effective_from = Date.new(2025, 1, 1)

Seeds::UpsertCreditCard.call(
  name: "RBC Avion Visa Infinite",
  issuer: "RBC",
  network: "Visa",
  annual_fee_cents: 12_000,
  currency: "Avion",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "1.25 Avion points per dollar on travel, 1 point elsewhere. Points transfer to British Airways " \
         "Avios and WestJet dollars.",
  rules: [
    { category: "travel", earning_rate: 1.25, notes: "1.25x on eligible travel purchases." },
    { category: "flights", earning_rate: 1.25, notes: "Flights are part of the 1.25x travel tier." },
    { category: "hotels", earning_rate: 1.25, notes: "Hotels are part of the 1.25x travel tier." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "RBC Avion Visa Infinite Privilege",
  issuer: "RBC",
  network: "Visa",
  annual_fee_cents: 39_900,
  currency: "Avion",
  base_earn_rate: 1.25,
  effective_from: effective_from,
  notes: "1.5 Avion points per dollar on travel, 1.25 points elsewhere. Airport lounge membership.",
  rules: [
    { category: "travel", earning_rate: 1.5, notes: "1.5x on eligible travel purchases." },
    { category: "flights", earning_rate: 1.5, notes: "Flights are part of the 1.5x travel tier." },
    { category: "hotels", earning_rate: 1.5, notes: "Hotels are part of the 1.5x travel tier." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "RBC ION+ Visa",
  issuer: "RBC",
  network: "Visa",
  annual_fee_cents: 4_800,
  currency: "Avion",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "$4/month. 3 Avion points per dollar on groceries, dining and food delivery, gas and EV charging, " \
         "daily transit and rideshare, streaming and digital subscriptions; 1 point elsewhere.",
  rules: [
    { category: "groceries", earning_rate: 3.0 },
    { category: "dining", earning_rate: 3.0, notes: "3x on restaurants and food delivery." },
    { category: "gas", earning_rate: 3.0, notes: "3x on gas and EV charging." },
    { category: "transit", earning_rate: 3.0, notes: "3x on daily transit and rideshare." },
    { category: "entertainment", earning_rate: 3.0, notes: "3x on streaming and digital subscriptions." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "RBC ION Visa",
  issuer: "RBC",
  network: "Visa",
  annual_fee_cents: 0,
  currency: "Avion",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "No fee. 1.5 Avion points per dollar on groceries, dining, gas, transit and streaming; 1 point elsewhere.",
  rules: [
    { category: "groceries", earning_rate: 1.5 },
    { category: "dining", earning_rate: 1.5, notes: "1.5x on restaurants and food delivery." },
    { category: "gas", earning_rate: 1.5, notes: "1.5x on gas and EV charging." },
    { category: "transit", earning_rate: 1.5, notes: "1.5x on daily transit and rideshare." },
    { category: "entertainment", earning_rate: 1.5, notes: "1.5x on streaming and digital subscriptions." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "RBC Cash Back Mastercard",
  issuer: "RBC",
  network: "Mastercard",
  annual_fee_cents: 0,
  currency: "Cash Back",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "No fee. 2% cash back on groceries up to $6,000/year, 1% on everything else.",
  rules: [
    { category: "groceries", earning_rate: 2.0, spend_cap_cents: 600_000,
      notes: "2% on the first $6,000/year of groceries; 1% after the cap." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "RBC Cash Back Preferred World Elite Mastercard",
  issuer: "RBC",
  network: "Mastercard",
  annual_fee_cents: 9_900,
  currency: "Cash Back",
  base_earn_rate: 1.5,
  effective_from: effective_from,
  notes: "Flat 1.5% cash back on all purchases.",
  rules: [
    { category: "general", earning_rate: 1.5, notes: "Flat 1.5% on all purchases; no category bonuses." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "RBC WestJet World Elite Mastercard",
  issuer: "RBC",
  network: "Mastercard",
  annual_fee_cents: 11_900,
  currency: "WestJet Dollars",
  base_earn_rate: 1.5,
  effective_from: effective_from,
  notes: "2% back in WestJet dollars on WestJet flights and WestJet Vacations packages, 1.5% on everything " \
         "else. Annual companion voucher and first checked bag free on WestJet.",
  rules: [
    { category: "flights", earning_rate: 2.0,
      notes: "2% applies to WestJet and WestJet Vacations purchases only; other airlines earn 1.5%." }
  ]
)
