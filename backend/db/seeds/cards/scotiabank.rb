effective_from = Date.new(2025, 1, 1)

Seeds::UpsertCreditCard.call(
  name: "Scotiabank Gold American Express",
  issuer: "Scotiabank",
  network: "Amex",
  annual_fee_cents: 12_000,
  currency: "Scene+",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "6 Scene+ points per dollar at Empire grocers (Sobeys, Safeway, FreshCo, IGA, Foodland), 5 points " \
         "on other groceries, dining and entertainment, 3 points on gas, daily transit and select streaming " \
         "services, 1 point elsewhere. No foreign transaction fee.",
  rules: [
    { category: "groceries", earning_rate: 5.0, notes: "5x at grocery stores; 6x at Empire banners." },
    { category: "dining", earning_rate: 5.0, notes: "5x on restaurants, fast food, bars and food delivery." },
    { category: "entertainment", earning_rate: 5.0,
      notes: "5x on entertainment (movies, theatre, ticket agencies); select streaming services earn 3x." },
    { category: "gas", earning_rate: 3.0 },
    { category: "transit", earning_rate: 3.0, notes: "3x on daily transit, taxis and rideshare." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "Scotiabank Passport Visa Infinite",
  issuer: "Scotiabank",
  network: "Visa",
  annual_fee_cents: 15_000,
  currency: "Scene+",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "3 Scene+ points per dollar at Empire grocers, 2 points on other groceries, dining, entertainment " \
         "and daily transit, 1 point elsewhere. No foreign transaction fee and six lounge visits a year.",
  rules: [
    { category: "groceries", earning_rate: 2.0, notes: "2x at grocery stores; 3x at Empire banners." },
    { category: "dining", earning_rate: 2.0 },
    { category: "entertainment", earning_rate: 2.0 },
    { category: "transit", earning_rate: 2.0, notes: "2x on daily transit, taxis and rideshare." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "Scotiabank American Express Card",
  issuer: "Scotiabank",
  network: "Amex",
  annual_fee_cents: 0,
  currency: "Scene+",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "No fee. 3 Scene+ points per dollar at Empire grocers, 2 points on other groceries, dining, " \
         "entertainment, gas, daily transit and select streaming, 1 point elsewhere.",
  rules: [
    { category: "groceries", earning_rate: 2.0, notes: "2x at grocery stores; 3x at Empire banners." },
    { category: "dining", earning_rate: 2.0 },
    { category: "entertainment", earning_rate: 2.0, notes: "2x on entertainment and select streaming." },
    { category: "gas", earning_rate: 2.0 },
    { category: "transit", earning_rate: 2.0 }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "Scotiabank Platinum American Express",
  issuer: "Scotiabank",
  network: "Amex",
  annual_fee_cents: 39_900,
  currency: "Scene+",
  base_earn_rate: 2.0,
  effective_from: effective_from,
  notes: "Flat 2 Scene+ points per dollar on all purchases. No foreign transaction fee and unlimited " \
         "lounge access.",
  rules: [
    { category: "general", earning_rate: 2.0, notes: "Flat 2x on all purchases; no category bonuses." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "Scotiabank Scene+ Visa",
  issuer: "Scotiabank",
  network: "Visa",
  annual_fee_cents: 0,
  currency: "Scene+",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "No fee. 2 Scene+ points per dollar at Empire grocers (merchant specific), 1 point elsewhere.",
  rules: [
    { category: "general", earning_rate: 1.0,
      notes: "Flat 1x on all purchases; the 2x Empire grocer bonus is merchant specific." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "Scotia Momentum Visa Infinite",
  issuer: "Scotiabank",
  network: "Visa",
  annual_fee_cents: 12_000,
  currency: "Cash Back",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "4% cash back on groceries and recurring bill payments, 2% on gas and daily transit, 1% elsewhere. " \
         "Each bonus tier is capped at $25,000/year of combined spend.",
  rules: [
    { category: "groceries", earning_rate: 4.0, spend_cap_cents: 2_500_000,
      notes: "4% shares a $25,000/year cap with recurring bills; 1% after the cap." },
    { category: "gas", earning_rate: 2.0, spend_cap_cents: 2_500_000,
      notes: "2% shares a $25,000/year cap with transit; 1% after the cap." },
    { category: "transit", earning_rate: 2.0, spend_cap_cents: 2_500_000,
      notes: "2% shares a $25,000/year cap with gas; 1% after the cap." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "Scotia Momentum No-Fee Visa",
  issuer: "Scotiabank",
  network: "Visa",
  annual_fee_cents: 0,
  currency: "Cash Back",
  base_earn_rate: 0.5,
  effective_from: effective_from,
  notes: "No fee. 1% cash back on gas, groceries, drugstores and recurring bill payments, 0.5% elsewhere.",
  rules: [
    { category: "gas", earning_rate: 1.0 },
    { category: "groceries", earning_rate: 1.0 },
    { category: "drugstore", earning_rate: 1.0 }
  ]
)
