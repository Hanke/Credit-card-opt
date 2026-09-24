effective_from = Date.new(2025, 1, 1)

Seeds::UpsertCreditCard.call(
  name: "Brim World Elite Mastercard",
  issuer: "Brim Financial",
  network: "Mastercard",
  annual_fee_cents: 19_900,
  currency: "Brim Rewards",
  base_earn_rate: 2.0,
  effective_from: effective_from,
  notes: "Flat 2 Brim points per dollar (2%) on all purchases, boosted rates at Brim partner merchants, " \
         "no foreign transaction fee, and free Boingo Wi-Fi.",
  rules: [
    { category: "general", earning_rate: 2.0,
      notes: "Flat 2x on all purchases; partner boosts are merchant specific." }
  ]
)
