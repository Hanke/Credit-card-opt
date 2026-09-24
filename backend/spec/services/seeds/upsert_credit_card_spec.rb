require "rails_helper"

RSpec.describe Seeds::UpsertCreditCard do
  let!(:currency) { create(:reward_currency, name: "Cash Back", cents_per_point: 1.0) }
  let(:effective_from) { Date.new(2025, 1, 1) }

  def upsert(**overrides)
    described_class.call(
      **{
        name: "Test Cash Back Card",
        issuer: "Test Bank",
        network: "Visa",
        annual_fee_cents: 9_900,
        currency: "Cash Back",
        base_earn_rate: 1.0,
        effective_from: effective_from,
        notes: "A card",
        rules: [
          { category: "groceries", earning_rate: 4.0, spend_cap_cents: 600_000, notes: "capped" },
          { category: "gas", earning_rate: 2.0 }
        ]
      }.merge(overrides)
    )
  end

  describe ".call" do
    it "creates the card with its currency and rules" do
      card = upsert

      expect(card).to be_persisted
      expect(card.reward_currency).to eq(currency)
      expect(card.annual_fee_cents).to eq(9_900)
      expect(card.reward_rules.order(:category).map { |r| [ r.category, r.earning_rate, r.spend_cap_cents, r.effective_from ] })
        .to eq([ [ "gas", 2.0, nil, effective_from ], [ "groceries", 4.0, 600_000, effective_from ] ])
    end

    it "accepts a RewardCurrency record as the currency" do
      card = upsert(currency: currency)

      expect(card.reward_currency).to eq(currency)
    end

    it "lets a rule override the card-level effective_from" do
      card = upsert(rules: [ { category: "dining", earning_rate: 3.0, effective_from: Date.new(2024, 6, 1) } ])

      expect(card.reward_rules.first.effective_from).to eq(Date.new(2024, 6, 1))
    end

    it "is idempotent: running twice does not duplicate cards or rules" do
      upsert

      expect { upsert }.not_to change { [ CreditCard.count, RewardRule.count ] }
    end

    it "refreshes card attributes and rule rates on a second run" do
      card = upsert

      upsert(annual_fee_cents: 0, rules: [ { category: "groceries", earning_rate: 5.0, spend_cap_cents: nil } ])

      card.reload
      expect(card.annual_fee_cents).to eq(0)
      grocery_rule = card.reward_rules.for_category("groceries").sole
      expect(grocery_rule.earning_rate).to eq(5.0)
      expect(grocery_rule.spend_cap_cents).to be_nil
    end

    it "keeps rules for other effective_from dates side by side" do
      upsert
      upsert(rules: [ { category: "groceries", earning_rate: 3.0, effective_from: Date.new(2026, 1, 1) } ])

      rates = RewardRule.for_category("groceries").order(:effective_from).pluck(:effective_from, :earning_rate)
      expect(rates).to eq([ [ effective_from, 4.0 ], [ Date.new(2026, 1, 1), 3.0 ] ])
    end

    it "raises when the named currency has not been seeded" do
      expect { upsert(currency: "Nope Points") }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "rolls back the card when a rule is invalid" do
      expect {
        upsert(rules: [ { category: "crypto", earning_rate: 1.0 } ])
      }.to raise_error(ActiveRecord::RecordInvalid)

      expect(CreditCard.where(name: "Test Cash Back Card")).not_to exist
    end
  end
end
