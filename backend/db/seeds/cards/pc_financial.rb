effective_from = Date.new(2025, 1, 1)

[
  {
    name: "PC Financial World Elite Mastercard",
    notes: "No fee. 45 PC Optimum points per dollar at Shoppers Drug Mart, 30 points at Loblaw grocery " \
           "banners, Esso and Mobil stations and PC Travel, 10 points (1%) everywhere else."
  },
  {
    name: "PC Financial World Mastercard",
    notes: "No fee. 35 PC Optimum points per dollar at Shoppers Drug Mart, 20 points at Loblaw grocery " \
           "banners and Esso/Mobil stations, 10 points (1%) everywhere else."
  },
  {
    name: "PC Financial Mastercard",
    notes: "No fee. 25 PC Optimum points per dollar at Shoppers Drug Mart, 10 points (1%) at Loblaw " \
           "banners and everywhere else."
  }
].each do |card|
  Seeds::UpsertCreditCard.call(
    name: card[:name],
    issuer: "PC Financial",
    network: "Mastercard",
    annual_fee_cents: 0,
    currency: "PC Optimum",
    base_earn_rate: 10.0,
    effective_from: effective_from,
    notes: card[:notes],
    rules: [
      { category: "general", earning_rate: 10.0,
        notes: "10 points per dollar (1%) outside Loblaw, Shoppers and Esso/Mobil, whose bonus rates are " \
               "merchant specific." }
    ]
  )
end
