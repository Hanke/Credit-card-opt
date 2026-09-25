require "rails_helper"

RSpec.describe CreditCardDetailSerializer do
  describe ".call" do
    let(:card) { create(:credit_card, :td_aeroplan_infinite, notes: "Good for flights") }

    it "adds notes, the full reward currency, and the current reward rules to the summary" do
      current = create(:reward_rule, credit_card: card, category: "dining", earning_rate: 1.5,
                       effective_from: Date.new(2024, 1, 1), notes: "Restaurants")
      create(:reward_rule, credit_card: card, category: "gas", effective_from: Date.new(2020, 1, 1),
             effective_to: Date.new(2023, 12, 31))

      payload = described_class.call(card)

      expect(payload).to include(CreditCardSerializer.call(card).except(:reward_currency))
      expect(payload).to include(
        notes: "Good for flights",
        reward_currency: {
          id: card.reward_currency.id,
          name: "Aeroplan",
          cash_back: false,
          cents_per_point: "1.5",
          description: "Generic points currency"
        },
        reward_rules: [
          {
            id: current.id,
            category: "dining",
            earning_rate: "1.5",
            spend_cap_cents: nil,
            effective_from: "2024-01-01",
            effective_to: nil,
            notes: "Restaurants"
          }
        ]
      )
    end
  end
end
