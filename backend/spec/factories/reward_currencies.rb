FactoryBot.define do
  factory :reward_currency do
    initialize_with { RewardCurrency.find_or_initialize_by(name: name) }

    sequence(:name) { |n| "Points #{n}" }
    cents_per_point { 1.0 }
    description { "Generic points currency" }

    trait :cash_back do
      name { "Cash Back" }
      cents_per_point { 1.0 }
    end

    trait :membership_rewards do
      name { "Membership Rewards" }
      cents_per_point { 1.0 }
    end

    trait :aeroplan do
      name { "Aeroplan" }
      cents_per_point { 1.5 }
    end

    trait :avion do
      name { "Avion" }
      cents_per_point { 1.0 }
    end

    trait :pc_optimum do
      name { "PC Optimum" }
      cents_per_point { 0.1 }
    end
  end
end
