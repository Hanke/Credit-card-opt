FactoryBot.define do
  factory :credit_card do
    sequence(:name) { |n| "Card #{n}" }
    issuer { "Amex" }
    network { "Amex" }
    annual_fee_cents { 0 }
    base_earn_rate { 1.0 }
    active { true }
    reward_currency

    trait :inactive do
      active { false }
    end

    trait :amex_cobalt do
      name { "Amex Cobalt" }
      issuer { "American Express" }
      network { "Amex" }
      annual_fee_cents { 15_600 }
      base_earn_rate { 1.0 }
      association :reward_currency, :membership_rewards
    end

    trait :td_aeroplan_infinite do
      name { "TD Aeroplan Visa Infinite" }
      issuer { "TD" }
      network { "Visa" }
      annual_fee_cents { 13_900 }
      base_earn_rate { 1.0 }
      association :reward_currency, :aeroplan
    end

    trait :td_cash_back_infinite do
      name { "TD Cash Back Visa Infinite" }
      issuer { "TD" }
      network { "Visa" }
      annual_fee_cents { 13_900 }
      base_earn_rate { 1.0 }
      association :reward_currency, :cash_back
    end

    trait :rbc_avion_infinite do
      name { "RBC Avion Visa Infinite" }
      issuer { "RBC" }
      network { "Visa" }
      annual_fee_cents { 12_000 }
      base_earn_rate { 1.0 }
      association :reward_currency, :avion
    end

    trait :pc_financial_mastercard do
      name { "PC Financial World Elite Mastercard" }
      issuer { "PC Financial" }
      network { "Mastercard" }
      annual_fee_cents { 0 }
      base_earn_rate { 10.0 }
      association :reward_currency, :pc_optimum
    end
  end
end
