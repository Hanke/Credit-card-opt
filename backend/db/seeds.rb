seeds_dir = Rails.root.join("db/seeds")

load seeds_dir.join("reward_currencies.rb")
Dir[seeds_dir.join("cards/*.rb").to_s].sort.each { |file| load file }

puts "Seeded #{RewardCurrency.count} reward currencies, #{CreditCard.count} credit cards " \
     "(#{CreditCard.active.count} active) and #{RewardRule.count} reward rules."
