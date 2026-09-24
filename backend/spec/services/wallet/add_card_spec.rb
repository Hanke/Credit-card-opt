require "rails_helper"

RSpec.describe Wallet::AddCard do
  describe ".call" do
    let(:user) { create(:user) }
    let(:card) { create(:credit_card) }

    it "adds the card to the user's wallet with added_at set to now" do
      freeze_time do
        result = described_class.call(user: user, credit_card_id: card.id)

        expect(result).to be_success
        expect(result.user_card).to be_persisted
        expect(result.user_card).to have_attributes(user: user, credit_card: card, added_at: Time.current)
      end
    end

    it "accepts the id as a string, as it arrives from params" do
      result = described_class.call(user: user, credit_card_id: card.id.to_s)

      expect(result).to be_success
      expect(user.credit_cards).to contain_exactly(card)
    end

    it "rejects a card that is already in the wallet" do
      create(:user_card, user: user, credit_card: card)

      result = described_class.call(user: user, credit_card_id: card.id)

      expect(result).not_to be_success
      expect(result.user_card).to be_nil
      expect(result.errors).to eq([ "Credit card is already in your wallet" ])
      expect(user.user_cards.count).to eq(1)
    end

    it "does not leave an unsaved entry on the user's association when the add is rejected" do
      create(:user_card, user: user, credit_card: card)

      described_class.call(user: user, credit_card_id: card.id)

      expect(user.user_cards.size).to eq(1)
      expect(user.user_cards).to all(be_persisted)
    end

    it "returns the duplicate error when the unique index rejects a concurrent insert" do
      allow_any_instance_of(UserCard).to receive(:save).and_raise(ActiveRecord::RecordNotUnique, "duplicate key")

      result = described_class.call(user: user, credit_card_id: card.id)

      expect(result).not_to be_success
      expect(result.errors).to eq([ "Credit card is already in your wallet" ])
    end

    it "rejects an inactive card" do
      inactive = create(:credit_card, :inactive)

      result = described_class.call(user: user, credit_card_id: inactive.id)

      expect(result).not_to be_success
      expect(result.errors).to eq([ "Credit card is not available" ])
      expect(user.user_cards).to be_empty
    end

    it "rejects an unknown or missing card id" do
      expect(described_class.call(user: user, credit_card_id: 0).errors).to eq([ "Credit card is not available" ])
      expect(described_class.call(user: user, credit_card_id: nil).errors).to eq([ "Credit card is not available" ])
    end

    it "lets different users add the same card" do
      create(:user_card, credit_card: card)

      expect(described_class.call(user: user, credit_card_id: card.id)).to be_success
    end
  end
end
