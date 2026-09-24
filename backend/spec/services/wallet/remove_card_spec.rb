require "rails_helper"

RSpec.describe Wallet::RemoveCard do
  describe ".call" do
    let(:user) { create(:user) }

    it "removes the card from the user's wallet and returns the removed entry" do
      user_card = create(:user_card, user: user)

      removed = described_class.call(user: user, credit_card_id: user_card.credit_card_id)

      expect(removed).to eq(user_card)
      expect(user.user_cards).to be_empty
    end

    it "raises RecordNotFound when the card is not in the wallet" do
      card = create(:credit_card)

      expect {
        described_class.call(user: user, credit_card_id: card.id)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not touch another user's wallet entry for the same card" do
      other_entry = create(:user_card)

      expect {
        described_class.call(user: user, credit_card_id: other_entry.credit_card_id)
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect(other_entry.reload).to be_persisted
    end
  end
end
