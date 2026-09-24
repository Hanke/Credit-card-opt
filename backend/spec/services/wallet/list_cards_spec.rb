require "rails_helper"

RSpec.describe Wallet::ListCards do
  describe ".call" do
    it "returns only the user's wallet entries, oldest first, with the card and currency preloaded" do
      user = create(:user)
      newer = create(:user_card, user: user, added_at: 1.day.ago)
      older = create(:user_card, user: user, added_at: 3.days.ago)
      create(:user_card)

      entries = described_class.call(user: user).to_a

      expect(entries).to eq([ older, newer ])
      expect(entries.first.association(:credit_card)).to be_loaded
      expect(entries.first.credit_card.association(:reward_currency)).to be_loaded
    end

    it "returns nothing for a user with an empty wallet" do
      expect(described_class.call(user: create(:user))).to be_empty
    end
  end
end
