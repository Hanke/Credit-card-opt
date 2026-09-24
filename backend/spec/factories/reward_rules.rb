FactoryBot.define do
  factory :reward_rule do
    credit_card
    category { "dining" }
    earning_rate { 5.0 }
    spend_cap_cents { nil }
    effective_from { Date.new(2020, 1, 1) }
    effective_to { nil }
  end
end
