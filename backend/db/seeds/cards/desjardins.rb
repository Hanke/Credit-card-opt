effective_from = Date.new(2025, 1, 1)

Seeds::UpsertCreditCard.call(
  name: "Desjardins Cash Back World Elite Mastercard",
  issuer: "Desjardins",
  network: "Mastercard",
  annual_fee_cents: 13_000,
  currency: "Cash Back",
  base_earn_rate: 1.0,
  effective_from: effective_from,
  notes: "4% cash back on groceries, 3% on restaurants and bars, 2% on recurring bill payments, 1% " \
         "elsewhere. Strong mobile device and travel insurance.",
  rules: [
    { category: "groceries", earning_rate: 4.0 },
    { category: "dining", earning_rate: 3.0, notes: "3% on restaurants and bars." }
  ]
)
