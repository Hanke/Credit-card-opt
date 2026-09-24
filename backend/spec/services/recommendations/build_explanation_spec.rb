require "rails_helper"

RSpec.describe Recommendations::BuildExplanation do
  describe ".call" do
    let(:points_currency) { create(:reward_currency, name: "MR Points", cents_per_point: 1.0) }
    let(:cash_back_currency) { create(:reward_currency, :cash_back) }
    let(:cobalt) { create(:credit_card, name: "Cobalt", reward_currency: points_currency, base_earn_rate: 1.0) }
    let(:simplii) { create(:credit_card, name: "Simplii Cash Back Visa", reward_currency: cash_back_currency, base_earn_rate: 0.5) }

    def explain(card:, rule:, rate:, points:, value_cents:, amount:, category:)
      described_class.call(
        card: card, rule: rule, rate: BigDecimal(rate.to_s), points: BigDecimal(points.to_s),
        value_cents: value_cents, amount: BigDecimal(amount.to_s), category: category
      )
    end

    context "with a points card" do
      it "matches the spec example for a category bonus" do
        rule = create(:reward_rule, credit_card: cobalt, category: "dining", earning_rate: 5.0)

        explanation = explain(card: cobalt, rule: rule, rate: 5, points: 750, value_cents: 750, amount: 150, category: "dining")

        expect(explanation).to eq("Cobalt earns 5x MR Points on dining. 150 × 5 = 750 pts ≈ $7.50")
      end

      it "explains the base rate fallback when no rule matches" do
        explanation = explain(card: cobalt, rule: nil, rate: 1, points: 150, value_cents: 150, amount: 150, category: "gas")

        expect(explanation).to eq("Cobalt has no gas bonus, so the base rate of 1x applies. 150 × 1 = 150 pts ≈ $1.50")
      end

      it "appends the annual spend cap when the rule has one" do
        rule = create(:reward_rule, credit_card: cobalt, category: "groceries", earning_rate: 5.0, spend_cap_cents: 250_000)

        explanation = explain(card: cobalt, rule: rule, rate: 5, points: 500, value_cents: 500, amount: 100, category: "groceries")

        expect(explanation).to eq("Cobalt earns 5x MR Points on groceries. 100 × 5 = 500 pts ≈ $5.00 (bonus rate applies up to $2,500/year)")
      end

      it "omits the spend cap when the cap is zero" do
        rule = create(:reward_rule, credit_card: cobalt, category: "dining", earning_rate: 5.0, spend_cap_cents: 0)

        explanation = explain(card: cobalt, rule: rule, rate: 5, points: 750, value_cents: 750, amount: 150, category: "dining")

        expect(explanation).not_to include("applies up to")
      end
    end

    context "with a cash-back card" do
      it "phrases the rate as a percentage and skips the points step" do
        rule = create(:reward_rule, credit_card: simplii, category: "dining", earning_rate: 4.0)

        explanation = explain(card: simplii, rule: rule, rate: 4, points: 600, value_cents: 600, amount: 150, category: "dining")

        expect(explanation).to eq("Simplii Cash Back Visa earns 4% cash back on dining. 150 × 4% = $6.00")
      end

      it "explains the base rate fallback as a percentage" do
        explanation = explain(card: simplii, rule: nil, rate: 0.5, points: 75, value_cents: 75, amount: 150, category: "travel")

        expect(explanation).to eq("Simplii Cash Back Visa has no travel bonus, so the base rate of 0.5% applies. 150 × 0.5% = $0.75")
      end

      it "appends the annual spend cap" do
        rule = create(:reward_rule, credit_card: simplii, category: "dining", earning_rate: 4.0, spend_cap_cents: 500_000)

        explanation = explain(card: simplii, rule: rule, rate: 4, points: 600, value_cents: 600, amount: 150, category: "dining")

        expect(explanation).to end_with("150 × 4% = $6.00 (bonus rate applies up to $5,000/year)")
      end

      it "recognises the currency name case-insensitively" do
        card = create(:credit_card, name: "Rogers", reward_currency: create(:reward_currency, name: "cash back"), base_earn_rate: 1.5)

        explanation = explain(card: card, rule: nil, rate: 1.5, points: 150, value_cents: 150, amount: 100, category: "gas")

        expect(explanation).to include("base rate of 1.5% applies. 100 × 1.5% = $1.50")
      end
    end

    context "formatting" do
      it "drops trailing zeros from database-scaled rates" do
        rule = create(:reward_rule, credit_card: cobalt, category: "dining", earning_rate: 1.0)

        explanation = explain(card: cobalt, rule: rule.reload, rate: rule.earning_rate, points: 150, value_cents: 150, amount: 150, category: "dining")

        expect(rule.earning_rate).to eq(BigDecimal("1.0000"))
        expect(explanation).to include("earns 1x MR Points").and include("150 × 1 = 150 pts")
        expect(explanation).not_to include("1.0000")
      end

      it "keeps fractional rates, amounts and points readable" do
        rule = create(:reward_rule, credit_card: cobalt, category: "dining", earning_rate: 1.25)

        explanation = explain(card: cobalt, rule: rule, rate: 1.25, points: 15.43, value_cents: 15, amount: 12.34, category: "dining")

        expect(explanation).to eq("Cobalt earns 1.25x MR Points on dining. 12.34 × 1.25 = 15.43 pts ≈ $0.15")
      end

      it "adds thousands separators to large amounts, points and values" do
        rule = create(:reward_rule, credit_card: cobalt, category: "travel", earning_rate: 2.0)

        explanation = explain(card: cobalt, rule: rule, rate: 2, points: 5000, value_cents: 5000, amount: 2500, category: "travel")

        expect(explanation).to eq("Cobalt earns 2x MR Points on travel. 2,500 × 2 = 5,000 pts ≈ $50.00")
      end

      it "keeps cents on a spend cap that is not a whole dollar amount" do
        rule = create(:reward_rule, credit_card: cobalt, category: "dining", earning_rate: 5.0, spend_cap_cents: 250_050)

        explanation = explain(card: cobalt, rule: rule, rate: 5, points: 750, value_cents: 750, amount: 150, category: "dining")

        expect(explanation).to end_with("(bonus rate applies up to $2,500.50/year)")
      end

      it "passes category labels through as lowercase words" do
        explanation = explain(card: cobalt, rule: nil, rate: 1, points: 100, value_cents: 100, amount: 100, category: "drugstore")

        expect(explanation).to start_with("Cobalt has no drugstore bonus")
      end
    end
  end
end
