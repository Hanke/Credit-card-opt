require "rails_helper"

RSpec.describe CreditCardSerializer do
  describe ".call" do
    it "returns the summary attributes with the reward currency id and name" do
      card = build_stubbed(:credit_card, :amex_cobalt)

      expect(described_class.call(card)).to eq(
        id: card.id,
        name: "Amex Cobalt",
        issuer: "American Express",
        network: "Amex",
        annual_fee_cents: 15_600,
        base_earn_rate: "1.0",
        reward_currency: { id: card.reward_currency.id, name: card.reward_currency.name }
      )
    end
  end

  describe ".collection" do
    it "serializes each card" do
      cards = build_stubbed_list(:credit_card, 2)

      expect(described_class.collection(cards).map { |c| c[:id] }).to eq(cards.map(&:id))
    end
  end
end
