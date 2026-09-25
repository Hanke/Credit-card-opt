require "rails_helper"

RSpec.describe Recommendations::ForPurchase do
  describe ".call" do
    let(:user) { create(:user) }
    let(:cobalt) { create(:credit_card, :amex_cobalt) }
    let(:aeroplan) { create(:credit_card, :td_aeroplan_infinite) }
    let(:pc) { create(:credit_card, :pc_financial_mastercard) }

    before do
      create(:reward_rule, credit_card: cobalt, category: "dining", earning_rate: 5.0)
    end

    def add_to_wallet(*cards)
      cards.each { |card| create(:user_card, user: user, credit_card: card) }
    end

    def count_queries(matching:)
      count = 0
      callback = ->(_name, _start, _finish, _id, payload) { count += 1 if payload[:sql].match?(matching) }
      ActiveSupport::Notifications.subscribed(callback, "sql.active_record") { yield }
      count
    end

    it "recommends the best card in the wallet and ranks the rest as comparisons" do
      add_to_wallet(pc, cobalt, aeroplan)

      result = described_class.call(user: user, amount: "150.00", category: "dining")

      expect(result).to be_success
      expect(result.recommendation).to include(credit_card_id: cobalt.id, estimated_value_cents: 750)
      expect(result.comparisons.map { |c| c[:credit_card_id] }).to eq([ aeroplan.id, pc.id ])
      expect(result.input).to eq(amount: BigDecimal("150"), category: "dining")
    end

    it "never includes the recommended card in the comparisons" do
      add_to_wallet(cobalt, aeroplan)

      result = described_class.call(user: user, amount: 20, category: "dining")

      expect(result.comparisons.map { |c| c[:credit_card_id] }).not_to include(result.recommendation[:credit_card_id])
    end

    it "returns an empty comparisons list when the wallet has one card" do
      add_to_wallet(cobalt)

      result = described_class.call(user: user, amount: 20, category: "dining")

      expect(result.recommendation).to include(credit_card_id: cobalt.id)
      expect(result.comparisons).to eq([])
    end

    it "limits the calculation to the given card ids" do
      add_to_wallet(cobalt, aeroplan, pc)

      result = described_class.call(user: user, amount: 150, category: "dining", user_card_ids: [ aeroplan.id, pc.id ])

      expect(result.recommendation).to include(credit_card_id: aeroplan.id)
      expect(result.comparisons.map { |c| c[:credit_card_id] }).to eq([ pc.id ])
    end

    it "silently ignores card ids that are not in the user's wallet" do
      add_to_wallet(aeroplan)
      create(:user_card, credit_card: cobalt)

      result = described_class.call(user: user, amount: 150, category: "dining", user_card_ids: [ cobalt.id, aeroplan.id, 0 ])

      expect(result).to be_success
      expect(result.recommendation).to include(credit_card_id: aeroplan.id)
      expect(result.comparisons).to eq([])
    end

    it "fails when none of the given card ids are in the user's wallet" do
      add_to_wallet(aeroplan)
      create(:user_card, credit_card: cobalt)

      result = described_class.call(user: user, amount: 150, category: "dining", user_card_ids: [ cobalt.id ])

      expect(result).not_to be_success
      expect(result.errors).to eq([ "None of the selected cards are in your wallet" ])
    end

    it "still ranks a wallet card that was deactivated after being added" do
      add_to_wallet(cobalt, aeroplan)
      cobalt.update!(active: false)

      result = described_class.call(user: user, amount: 150, category: "dining")

      expect(result.recommendation).to include(credit_card_id: cobalt.id)
    end

    it "loads the wallet once" do
      add_to_wallet(cobalt, aeroplan)

      wallet_queries = count_queries(matching: /FROM "user_cards"/) do
        described_class.call(user: user, amount: 150, category: "dining", user_card_ids: [ cobalt.id ])
      end

      expect(wallet_queries).to eq(1)
    end

    it "fails when the wallet is empty" do
      create(:user_card, credit_card: cobalt)

      result = described_class.call(user: user, amount: 150, category: "dining")

      expect(result).not_to be_success
      expect(result.recommendation).to be_nil
      expect(result.errors).to eq([ "Add a card to your wallet first" ])
    end

    it "fails with validation messages for a bad amount or category before touching the wallet" do
      expect(described_class.call(user: user, amount: 0, category: "dining").errors).to eq([ "Amount must be greater than 0" ])
      expect(described_class.call(user: user, amount: 1_000_001, category: "dining").errors).to eq([ "Amount must be less than or equal to 1000000" ])
      expect(described_class.call(user: user, amount: "12abc", category: "dining").errors).to eq([ "Amount is not a number" ])
      expect(described_class.call(user: user, amount: 10, category: "crypto").errors).to eq([ "Category is not a supported purchase category" ])
      expect(described_class.call(user: user, amount: 10, category: "dining", user_card_ids: [ "x" ]).errors).to eq([ "User card ids must be whole numbers" ])
      expect(described_class.call(user: user, amount: nil, category: nil).errors).to include("Amount can't be blank", "Category can't be blank")
    end
  end
end
