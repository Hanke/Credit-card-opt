effective_from = Date.new(2025, 1, 1)

[
  {
    name: "Tangerine Money-Back Credit Card",
    notes: "No fee. 2% cash back in two categories of your choice (three with a Tangerine savings " \
           "account), 0.5% on everything else. Seeded with groceries and dining as the chosen categories."
  },
  {
    name: "Tangerine World Mastercard",
    notes: "No fee. Same earn structure as the Money-Back card with World Mastercard perks: 2% cash back " \
           "in two chosen categories (three with a savings account), 0.5% elsewhere. Seeded with groceries " \
           "and dining as the chosen categories."
  }
].each do |card|
  Seeds::UpsertCreditCard.call(
    name: card[:name],
    issuer: "Tangerine",
    network: "Mastercard",
    annual_fee_cents: 0,
    currency: "Cash Back",
    base_earn_rate: 0.5,
    effective_from: effective_from,
    notes: card[:notes],
    rules: [
      { category: "groceries", earning_rate: 2.0,
        notes: "Chosen category. Options include groceries, restaurants, gas, drugstores, entertainment, " \
               "recurring bills, home improvement, furniture, hotels, public transit and parking." },
      { category: "dining", earning_rate: 2.0,
        notes: "Chosen category (restaurants). Swap for any other Tangerine category the cardholder picked." }
    ]
  )
end
