require "rails_helper"

RSpec.describe Recommendations::Calculate do
  describe ".call" do
    let(:today) { Date.new(2026, 9, 24) }

    it "applies the matching category rule to Amex Cobalt for dining" do
      cobalt = create(:credit_card, :amex_cobalt)
      create(:reward_rule, credit_card: cobalt, category: "dining", earning_rate: 5.0)

      result = described_class.call(amount: BigDecimal("150"), category: "dining", cards: [ cobalt ], on: today).first

      expect(result).to include(
        credit_card_id: cobalt.id,
        card_name: "Amex Cobalt",
        issuer: "American Express",
        reward_currency: "Membership Rewards",
        cash_back: false,
        earning_rate: BigDecimal("5"),
        points_earned: BigDecimal("750"),
        estimated_value_cents: 750,
        rule_applied: "Dining rule",
        spend_cap_cents: nil
      )
      expect(result[:explanation]).to eq("Amex Cobalt earns 5x Membership Rewards on dining. 150 × 5 = 750 pts ≈ $7.50")
    end

    it "gives every result a non-empty explanation whose numbers match the numeric fields" do
      cash_back = create(:credit_card, name: "Simplii Cash Back", reward_currency: create(:reward_currency, :cash_back), base_earn_rate: 0.5)
      create(:reward_rule, credit_card: cash_back, category: "dining", earning_rate: 4.0, spend_cap_cents: 500_000)
      aeroplan = create(:credit_card, :td_aeroplan_infinite)
      pc = create(:credit_card, :pc_financial_mastercard)

      results = described_class.call(amount: BigDecimal("12.34"), category: "dining", cards: [ cash_back, aeroplan, pc ], on: today)

      expect(results.map { |result| result[:explanation] }).to all(be_a(String).and be_present)
      results.each do |result|
        expect(result[:explanation]).to include(format("$%.2f", result[:estimated_value_cents] / 100.0))
        expect(result[:explanation]).to include("× #{result[:earning_rate].to_i}")
      end
      expect(results.find { |result| result[:card_name] == "Simplii Cash Back" }[:explanation]).to eq(
        "Simplii Cash Back earns 4% cash back on dining. 12.34 × 4% = $0.49 (bonus rate applies up to $5,000/year)"
      )
      expect(results.find { |result| result[:card_name] == "TD Aeroplan Visa Infinite" }[:explanation]).to eq(
        "TD Aeroplan Visa Infinite has no dining bonus, so the base rate of 1x applies. 12.34 × 1 = 12.34 pts ≈ $0.19"
      )
      expect(results.find { |result| result[:card_name] == "PC Financial World Elite Mastercard" }[:explanation]).to eq(
        "PC Financial World Elite Mastercard has no dining bonus, so the base rate of 10x applies. 12.34 × 10 = 123.4 pts ≈ $0.12"
      )
    end

    it "matches the spec example: Cobalt 750, TD Aeroplan 225, RBC Avion 150 cents on $150 dining" do
      cobalt = create(:credit_card, :amex_cobalt)
      create(:reward_rule, credit_card: cobalt, category: "dining", earning_rate: 5.0)
      aeroplan = create(:credit_card, :td_aeroplan_infinite)
      avion = create(:credit_card, :rbc_avion_infinite)
      create(:reward_rule, credit_card: avion, category: "travel", earning_rate: 1.25)

      results = described_class.call(amount: BigDecimal("150"), category: "dining", cards: [ avion, aeroplan, cobalt ], on: today)

      expect(results.map { |result| result.values_at(:card_name, :points_earned, :estimated_value_cents, :rule_applied) }).to eq([
        [ "Amex Cobalt", BigDecimal("750"), 750, "Dining rule" ],
        [ "TD Aeroplan Visa Infinite", BigDecimal("150"), 225, "Base earn rate" ],
        [ "RBC Avion Visa Infinite", BigDecimal("150"), 150, "Base earn rate" ]
      ])
    end

    it "values a cash-back percentage directly as cents" do
      td_cash_back = create(:credit_card, :td_cash_back_infinite)
      create(:reward_rule, credit_card: td_cash_back, category: "groceries", earning_rate: 3.0, spend_cap_cents: 1_500_000)

      groceries = described_class.call(amount: BigDecimal("150"), category: "groceries", cards: [ td_cash_back ], on: today).first
      dining = described_class.call(amount: BigDecimal("150"), category: "dining", cards: [ td_cash_back ], on: today).first

      expect(groceries).to include(reward_currency: "Cash Back", cash_back: true, points_earned: BigDecimal("450"), estimated_value_cents: 450, spend_cap_cents: 1_500_000)
      expect(dining).to include(points_earned: BigDecimal("150"), estimated_value_cents: 150, rule_applied: "Base earn rate")
    end

    it "values TD Aeroplan dining at the base rate and 1.5 cents per point" do
      aeroplan = create(:credit_card, :td_aeroplan_infinite)

      result = described_class.call(amount: BigDecimal("150"), category: "dining", cards: [ aeroplan ], on: today).first

      expect(result).to include(
        earning_rate: BigDecimal("1"),
        points_earned: BigDecimal("150"),
        estimated_value_cents: 225,
        rule_applied: "Base earn rate"
      )
    end

    it "falls back to the base rate when the only rule has expired" do
      card = create(:credit_card, base_earn_rate: 1.0)
      create(:reward_rule, :expired, credit_card: card, category: "dining", earning_rate: 5.0)

      result = described_class.call(amount: BigDecimal("100"), category: "dining", cards: [ card ], on: today).first

      expect(result).to include(earning_rate: BigDecimal("1"), points_earned: BigDecimal("100"), rule_applied: "Base earn rate")
    end

    it "ignores rules that have not started yet" do
      card = create(:credit_card, base_earn_rate: 1.0)
      create(:reward_rule, :future, credit_card: card, category: "dining", earning_rate: 5.0)

      result = described_class.call(amount: BigDecimal("100"), category: "dining", cards: [ card ], on: today).first

      expect(result).to include(earning_rate: BigDecimal("1"), rule_applied: "Base earn rate")
    end

    it "treats the effective_from and effective_to dates as inclusive" do
      card = create(:credit_card, base_earn_rate: 1.0)
      create(:reward_rule, credit_card: card, category: "dining", earning_rate: 3.0, effective_from: today, effective_to: today)

      result = described_class.call(amount: BigDecimal("100"), category: "dining", cards: [ card ], on: today).first

      expect(result).to include(earning_rate: BigDecimal("3"))
    end

    it "breaks ties between rules with the same start date deterministically" do
      card = create(:credit_card)
      first = create(:reward_rule, credit_card: card, category: "dining", earning_rate: 3.0, effective_from: Date.new(2024, 1, 1))
      second = create(:reward_rule, credit_card: card, category: "dining", earning_rate: 4.0, effective_from: Date.new(2024, 1, 1))

      result = described_class.call(amount: BigDecimal("100"), category: "dining", cards: [ card ], on: today).first

      expect(result).to include(earning_rate: second.earning_rate)
      expect(result).not_to include(earning_rate: first.earning_rate)
    end

    it "accepts the effective date as a string" do
      card = create(:credit_card)
      create(:reward_rule, credit_card: card, category: "dining", earning_rate: 5.0, effective_from: today, effective_to: today)

      result = described_class.call(amount: BigDecimal("100"), category: "dining", cards: [ card ], on: today.iso8601).first

      expect(result).to include(earning_rate: BigDecimal("5"))
    end

    it "picks the most recently effective rule when several overlap" do
      card = create(:credit_card)
      create(:reward_rule, credit_card: card, category: "dining", earning_rate: 3.0, effective_from: Date.new(2020, 1, 1))
      create(:reward_rule, credit_card: card, category: "dining", earning_rate: 4.0, effective_from: Date.new(2024, 1, 1))
      create(:reward_rule, credit_card: card, category: "dining", earning_rate: 6.0, effective_from: Date.new(2030, 1, 1))

      result = described_class.call(amount: BigDecimal("100"), category: "dining", cards: [ card ], on: today).first

      expect(result).to include(earning_rate: BigDecimal("4"))
    end

    it "ignores rules for other categories" do
      card = create(:credit_card, base_earn_rate: 1.0)
      create(:reward_rule, credit_card: card, category: "groceries", earning_rate: 5.0)

      result = described_class.call(amount: BigDecimal("100"), category: "dining", cards: [ card ], on: today).first

      expect(result).to include(earning_rate: BigDecimal("1"), rule_applied: "Base earn rate")
    end

    it "falls back to the base rate for an unknown category instead of raising" do
      card = create(:credit_card, base_earn_rate: 2.0)
      create(:reward_rule, credit_card: card, category: "dining", earning_rate: 5.0)

      results = described_class.call(amount: BigDecimal("100"), category: "spaceships", cards: [ card ], on: today)

      expect(results.first).to include(earning_rate: BigDecimal("2"), points_earned: BigDecimal("200"), rule_applied: "Base earn rate")
    end

    it "passes the spend cap through without applying it to the math" do
      card = create(:credit_card)
      create(:reward_rule, credit_card: card, category: "dining", earning_rate: 5.0, spend_cap_cents: 10_000)

      result = described_class.call(amount: BigDecimal("500"), category: "dining", cards: [ card ], on: today).first

      expect(result).to include(points_earned: BigDecimal("2500"), spend_cap_cents: 10_000)
    end

    it "rounds $33.33 at 1.25x to 41.66 points and 42 cents" do
      card = create(:credit_card, :rbc_avion_infinite)
      create(:reward_rule, credit_card: card, category: "travel", earning_rate: 1.25)

      result = described_class.call(amount: BigDecimal("33.33"), category: "travel", cards: [ card ], on: today).first

      expect(result).to include(points_earned: BigDecimal("41.66"), estimated_value_cents: 42)
      expect(result[:explanation]).to end_with("33.33 × 1.25 = 41.66 pts ≈ $0.42")
    end

    it "does BigDecimal math and rounds points to two places and value to whole cents" do
      pc = create(:credit_card, :pc_financial_mastercard, base_earn_rate: 10.0)
      create(:reward_rule, credit_card: pc, category: "groceries", earning_rate: 33.3333)

      result = described_class.call(amount: BigDecimal("12.34"), category: "groceries", cards: [ pc ], on: today).first

      expect(result[:points_earned]).to be_a(BigDecimal)
      expect(result[:points_earned]).to eq(BigDecimal("411.33"))
      expect(result[:estimated_value_cents]).to be_a(Integer)
      expect(result[:estimated_value_cents]).to eq(41)
    end

    it "sorts by value desc, then points desc, then card name asc" do
      cents = create(:reward_currency, cents_per_point: 1.0)
      aeroplan = create(:reward_currency, :aeroplan)
      low_value = create(:credit_card, name: "Aardvark", reward_currency: cents, base_earn_rate: 1.0)
      high_value = create(:credit_card, name: "Zebra", reward_currency: aeroplan, base_earn_rate: 1.0)
      tie_more_points = create(:credit_card, name: "Manatee", reward_currency: cents, base_earn_rate: 1.5)
      tie_b = create(:credit_card, name: "Bison", reward_currency: aeroplan, base_earn_rate: 1.0)
      tie_a = create(:credit_card, name: "Antelope", reward_currency: aeroplan, base_earn_rate: 1.0)

      names = described_class.call(
        amount: BigDecimal("100"), category: "dining",
        cards: [ low_value, high_value, tie_more_points, tie_b, tie_a ], on: today
      ).map { |result| result[:card_name] }

      expect(names).to eq(%w[Manatee Antelope Bison Zebra Aardvark])
    end

    it "orders name ties case-insensitively" do
      currency = create(:reward_currency)
      lower = create(:credit_card, name: "amex Cobalt", reward_currency: currency)
      upper = create(:credit_card, name: "Zebra", reward_currency: currency)

      names = described_class.call(amount: BigDecimal("100"), category: "dining", cards: [ upper, lower ], on: today)
        .map { |result| result[:card_name] }

      expect(names).to eq([ "amex Cobalt", "Zebra" ])
    end

    it "returns an empty list when given no cards" do
      expect(described_class.call(amount: BigDecimal("100"), category: "dining", cards: [], on: today)).to eq([])
    end

    it "defaults the effective date to today" do
      card = create(:credit_card, base_earn_rate: 1.0)
      create(:reward_rule, credit_card: card, category: "dining", earning_rate: 5.0,
                           effective_from: Date.current, effective_to: Date.current)

      result = described_class.call(amount: BigDecimal("100"), category: "dining", cards: [ card ]).first

      expect(result).to include(earning_rate: BigDecimal("5"))
    end

    it "loads currencies and rules with a constant number of queries" do
      cards = create_list(:credit_card, 5)
      cards.each { |card| create(:reward_rule, credit_card: card) }
      reloaded = CreditCard.where(id: cards.map(&:id)).to_a

      query_count = 0
      counter = ->(*, payload) { query_count += 1 unless payload[:name].in?([ "SCHEMA", "TRANSACTION" ]) }
      ActiveSupport::Notifications.subscribed(counter, "sql.active_record") do
        described_class.call(amount: BigDecimal("50"), category: "dining", cards: reloaded, on: today)
      end

      expect(query_count).to eq(2)
      expect(reloaded.first.association(:reward_currency)).to be_loaded
    end
  end
end
