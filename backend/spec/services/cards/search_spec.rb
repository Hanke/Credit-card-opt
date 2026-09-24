require "rails_helper"

RSpec.describe Cards::Search do
  describe ".call" do
    let!(:cobalt) { create(:credit_card, :amex_cobalt) }
    let!(:td_aeroplan) { create(:credit_card, :td_aeroplan_infinite) }
    let!(:inactive_amex) { create(:credit_card, :inactive, name: "Amex Platinum", issuer: "American Express") }

    it "filters active cards by name or issuer" do
      expect(described_class.call(query: "amex")).to contain_exactly(cobalt)
    end

    it "never returns inactive cards" do
      expect(described_class.call(query: "platinum")).to be_empty
      expect(described_class.call).not_to include(inactive_amex)
    end

    it "returns every active card for a blank or missing query" do
      expect(described_class.call(query: "   ")).to contain_exactly(cobalt, td_aeroplan)
      expect(described_class.call).to contain_exactly(cobalt, td_aeroplan)
    end

    it "orders by issuer then name" do
      amex_gold = create(:credit_card, name: "Amex Gold", issuer: "American Express")

      expect(described_class.call).to eq([ cobalt, amex_gold, td_aeroplan ])
    end

    it "caps the number of results at MAX_RESULTS" do
      stub_const("Cards::Search::MAX_RESULTS", 1)

      expect(described_class.call.to_a.size).to eq(1)
    end

    it "preloads the reward currency" do
      card = described_class.call(query: "cobalt").first

      expect(card.association(:reward_currency)).to be_loaded
    end
  end
end
