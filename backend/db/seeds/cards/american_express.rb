effective_from = Date.new(2025, 1, 1)

Seeds::UpsertCreditCard.call(
  name: "Amex Cobalt",
  issuer: "American Express",
  network: "Amex",
  annual_fee_cents: 19_188,
  currency: "Membership Rewards",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "$15.99/month. 5x on eats and drinks (groceries, restaurants, bars, food delivery) up to " \
         "$2,500/month, 3x on streaming, 2x on travel and transit including gas, 1x elsewhere.",
  rules: [
    { category: "groceries", earning_rate: 5.0, spend_cap_cents: 3_000_000,
      notes: "5x eats and drinks, capped at $2,500/month ($30,000/year) combined with dining." },
    { category: "dining", earning_rate: 5.0, spend_cap_cents: 3_000_000,
      notes: "5x eats and drinks, capped at $2,500/month ($30,000/year) combined with groceries." },
    { category: "entertainment", earning_rate: 3.0, notes: "3x on eligible streaming subscriptions." },
    { category: "travel", earning_rate: 2.0, notes: "2x on travel and transit." },
    { category: "transit", earning_rate: 2.0, notes: "2x on travel and transit, including rideshare." },
    { category: "gas", earning_rate: 2.0, notes: "Gas is included in the 2x travel and transit tier." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "Amex Gold Rewards Card",
  issuer: "American Express",
  network: "Amex",
  annual_fee_cents: 25_000,
  currency: "Membership Rewards",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "2x on travel (flights, hotels, car rentals, cruises, tours), 2x on gas, groceries and " \
         "drugstores, 1x elsewhere. Includes a $100 annual travel credit.",
  rules: [
    { category: "travel", earning_rate: 2.0, notes: "2x on eligible travel purchases." },
    { category: "flights", earning_rate: 2.0, notes: "Flights are part of the 2x travel tier." },
    { category: "hotels", earning_rate: 2.0, notes: "Hotels are part of the 2x travel tier." },
    { category: "gas", earning_rate: 2.0 },
    { category: "groceries", earning_rate: 2.0 },
    { category: "drugstore", earning_rate: 2.0 }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "Amex Platinum Card",
  issuer: "American Express",
  network: "Amex",
  annual_fee_cents: 79_900,
  currency: "Membership Rewards",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "2x on dining and food delivery, 2x on travel, 1x elsewhere. Lounge access and a $200 " \
         "annual travel credit offset the fee.",
  rules: [
    { category: "dining", earning_rate: 2.0, notes: "2x on restaurants, bars and food delivery." },
    { category: "travel", earning_rate: 2.0, notes: "2x on eligible travel purchases." },
    { category: "flights", earning_rate: 2.0, notes: "Flights are part of the 2x travel tier." },
    { category: "hotels", earning_rate: 2.0, notes: "Hotels are part of the 2x travel tier." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "Amex Green Card",
  issuer: "American Express",
  network: "Amex",
  annual_fee_cents: 0,
  currency: "Membership Rewards",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "No-fee flat-rate card: 1 Membership Rewards point per dollar on everything.",
  rules: [
    { category: "general", earning_rate: 1.0, notes: "Flat 1x on all purchases; no category bonuses." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "Amex SimplyCash Preferred Card",
  issuer: "American Express",
  network: "Amex",
  annual_fee_cents: 11_988,
  currency: "Cash Back",
  base_earn_rate: 2.0,
  effective_from: effective_from,
  notes: "$9.99/month. 4% cash back on gas and groceries up to $30,000/year combined, 2% on everything else.",
  rules: [
    { category: "gas", earning_rate: 4.0, spend_cap_cents: 3_000_000,
      notes: "4% on gas, sharing a $30,000/year cap with groceries; 2% after the cap." },
    { category: "groceries", earning_rate: 4.0, spend_cap_cents: 3_000_000,
      notes: "4% on groceries, sharing a $30,000/year cap with gas; 2% after the cap." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "Amex SimplyCash Card",
  issuer: "American Express",
  network: "Amex",
  annual_fee_cents: 0,
  currency: "Cash Back",
  base_earn_rate: 1.25,
  effective_from: effective_from,
  notes: "No fee. 2% cash back on gas and groceries up to $15,000/year combined, 1.25% on everything else.",
  rules: [
    { category: "gas", earning_rate: 2.0, spend_cap_cents: 1_500_000,
      notes: "2% on gas, sharing a $15,000/year cap with groceries; 1.25% after the cap." },
    { category: "groceries", earning_rate: 2.0, spend_cap_cents: 1_500_000,
      notes: "2% on groceries, sharing a $15,000/year cap with gas; 1.25% after the cap." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "Amex Aeroplan Card",
  issuer: "American Express",
  network: "Amex",
  annual_fee_cents: 12_000,
  currency: "Aeroplan",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "2x on Air Canada and Air Canada Vacations purchases, 1.5x on dining and food delivery, 1x elsewhere.",
  rules: [
    { category: "flights", earning_rate: 2.0,
      notes: "2x applies to Air Canada and Air Canada Vacations purchases only; other airlines earn 1x." },
    { category: "dining", earning_rate: 1.5, notes: "1.5x on restaurants, bars and food delivery." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "Amex Aeroplan Reserve Card",
  issuer: "American Express",
  network: "Amex",
  annual_fee_cents: 59_900,
  currency: "Aeroplan",
  base_earn_rate: 1.25,
  effective_from: effective_from,
  notes: "3x on Air Canada and Air Canada Vacations purchases, 2x on dining and food delivery, 1.25x " \
         "elsewhere. Maple Leaf Lounge access and Air Canada priority perks.",
  rules: [
    { category: "flights", earning_rate: 3.0,
      notes: "3x applies to Air Canada and Air Canada Vacations purchases only; other airlines earn 1.25x." },
    { category: "dining", earning_rate: 2.0, notes: "2x on restaurants, bars and food delivery." }
  ]
)

Seeds::UpsertCreditCard.call(
  name: "Amex Marriott Bonvoy Card",
  issuer: "American Express",
  network: "Amex",
  annual_fee_cents: 12_000,
  currency: "Marriott Bonvoy",
  base_earn_rate: 2.0,
  effective_from: effective_from,
  notes: "5 Bonvoy points per dollar at Marriott Bonvoy hotels, 2 points elsewhere. Annual free night " \
         "award (up to 35,000 points) on renewal.",
  rules: [
    { category: "hotels", earning_rate: 5.0,
      notes: "5x applies to stays at participating Marriott Bonvoy hotels only; other hotels earn 2x." }
  ]
)
