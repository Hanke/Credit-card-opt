FactoryBot.define do
  factory :reward_currency do
    sequence(:name) { |n| "Points #{n}" }
    cents_per_point { 1.0 }
    description { "Generic points currency" }

    trait :aeroplan do
      name { "Aeroplan" }
      cents_per_point { 1.5 }
    end

    trait :pc_optimum do
      name { "PC Optimum" }
      cents_per_point { 0.1 }
    end
  end
end
