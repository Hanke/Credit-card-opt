require "rails_helper"

RSpec.describe Cards::Find do
  describe ".call" do
    it "returns the active card with its currency and current rules preloaded" do
      card = create(:credit_card)
      create(:reward_rule, credit_card: card)

      found = described_class.call(id: card.id)

      expect(found).to eq(card)
      expect(found.association(:reward_currency)).to be_loaded
      expect(found.association(:current_reward_rules)).to be_loaded
    end

    it "raises RecordNotFound for an unknown id" do
      expect { described_class.call(id: 0) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "raises RecordNotFound for an inactive card" do
      card = create(:credit_card, :inactive)

      expect { described_class.call(id: card.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
