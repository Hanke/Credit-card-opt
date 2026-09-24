require "rails_helper"

RSpec.describe Recommendations::BuildExplanation do
  describe ".call" do
    let(:currency) { create(:reward_currency, name: "Membership Rewards", cents_per_point: 1.0) }
    let(:card) { create(:credit_card, name: "Amex Cobalt", reward_currency: currency, base_earn_rate: 1.0) }

    it "describes the category rule, the earnings, and the spend cap" do
      rule = create(:reward_rule, credit_card: card, category: "dining", earning_rate: 5.0, spend_cap_cents: 250_000)

      explanation = described_class.call(
        card: card, rule: rule, amount: BigDecimal("150"), category: "dining",
        earning_rate: BigDecimal("5"), points_earned: BigDecimal("750"), estimated_value_cents: 750
      )

      expect(explanation).to eq(
        "Amex Cobalt earns 5x on dining. " \
        "Spending $150.00 earns 750 Membership Rewards worth about $7.50. " \
        "This rate applies up to $2,500.00 of spend."
      )
    end

    it "omits the spend cap sentence when the cap is zero" do
      rule = create(:reward_rule, credit_card: card, category: "dining", earning_rate: 5.0, spend_cap_cents: 0)

      explanation = described_class.call(
        card: card, rule: rule, amount: BigDecimal("150"), category: "dining",
        earning_rate: BigDecimal("5"), points_earned: BigDecimal("750"), estimated_value_cents: 750
      )

      expect(explanation).not_to include("applies up to")
    end

    it "omits the spend cap sentence when the rule has no cap" do
      rule = create(:reward_rule, credit_card: card, category: "dining", earning_rate: 5.0)

      explanation = described_class.call(
        card: card, rule: rule, amount: BigDecimal("150"), category: "dining",
        earning_rate: BigDecimal("5"), points_earned: BigDecimal("750"), estimated_value_cents: 750
      )

      expect(explanation).not_to include("applies up to")
    end

    it "explains the base rate fallback when no rule matches" do
      explanation = described_class.call(
        card: card, rule: nil, amount: BigDecimal("150"), category: "gas",
        earning_rate: BigDecimal("1"), points_earned: BigDecimal("150"), estimated_value_cents: 150
      )

      expect(explanation).to eq(
        "Amex Cobalt has no gas rule, so its base rate of 1x applies. " \
        "Spending $150.00 earns 150 Membership Rewards worth about $1.50."
      )
    end

    it "keeps fractional rates and points readable" do
      rule = create(:reward_rule, credit_card: card, category: "dining", earning_rate: 1.25)

      explanation = described_class.call(
        card: card, rule: rule, amount: BigDecimal("12.34"), category: "dining",
        earning_rate: BigDecimal("1.25"), points_earned: BigDecimal("15.43"), estimated_value_cents: 15
      )

      expect(explanation).to include("earns 1.25x on dining").and include("earns 15.43 Membership Rewards worth about $0.15")
    end
  end
end
