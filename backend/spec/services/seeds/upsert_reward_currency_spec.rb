require "rails_helper"

RSpec.describe Seeds::UpsertRewardCurrency do
  describe ".call" do
    it "creates a currency that does not exist yet" do
      currency = described_class.call(name: "Aeroplan", cents_per_point: 1.5, description: "Air Canada")

      expect(currency).to be_persisted
      expect(currency.cents_per_point).to eq(1.5)
      expect(currency.description).to eq("Air Canada")
    end

    it "updates an existing currency matched by name instead of creating another" do
      existing = create(:reward_currency, name: "Aeroplan", cents_per_point: 1.0)

      expect {
        described_class.call(name: "aeroplan", cents_per_point: 1.5, description: "revalued")
      }.not_to change(RewardCurrency, :count)

      expect(existing.reload.cents_per_point).to eq(1.5)
      expect(existing.description).to eq("revalued")
    end

    it "raises on invalid attributes" do
      expect {
        described_class.call(name: "Broken", cents_per_point: -1)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
