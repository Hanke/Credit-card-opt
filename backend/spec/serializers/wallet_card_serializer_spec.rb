require "rails_helper"

RSpec.describe WalletCardSerializer do
  describe ".call" do
    it "returns the card summary with the card's active flag and the wallet's added_at" do
      card = build_stubbed(:credit_card, :amex_cobalt)
      user_card = build_stubbed(:user_card, credit_card: card, added_at: Time.zone.parse("2026-09-24T12:00:00Z"))

      expect(described_class.call(user_card)).to eq(
        CreditCardSerializer.call(card).merge(active: true, added_at: "2026-09-24T12:00:00Z")
      )
    end

    it "reports active: false for a card that was deactivated after being added" do
      user_card = build_stubbed(:user_card, credit_card: build_stubbed(:credit_card, :inactive))

      expect(described_class.call(user_card)).to include(active: false)
    end
  end
end
