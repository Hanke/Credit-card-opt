module Recommendations
  class ForPurchase
    EMPTY_WALLET_ERROR = "Add a card to your wallet first".freeze
    NO_SELECTED_CARDS_ERROR = "None of the selected cards are in your wallet".freeze

    def self.call(user:, amount:, category:, user_card_ids: nil)
      new(user: user, amount: amount, category: category, user_card_ids: user_card_ids).call
    end

    def initialize(user:, amount:, category:, user_card_ids: nil)
      @user = user
      @purchase = PurchaseParams.new(amount: amount, category: category, user_card_ids: user_card_ids)
    end

    def call
      return Result.failure(purchase.errors.full_messages) if purchase.invalid?

      wallet = Wallet::ListCards.call(user: user).to_a
      return Result.failure(EMPTY_WALLET_ERROR) if wallet.empty?

      cards = select_cards(wallet)
      return Result.failure(NO_SELECTED_CARDS_ERROR) if cards.empty?

      recommendation, *comparisons = Calculate.call(amount: purchase.amount, category: purchase.category, cards: cards)

      Result.success(
        recommendation: recommendation,
        comparisons: comparisons,
        input: { amount: purchase.amount, category: purchase.category }
      )
    end

    private

    attr_reader :user, :purchase

    def select_cards(wallet)
      selected = purchase.user_card_ids
      wallet = wallet.select { |entry| selected.include?(entry.credit_card_id) } if selected
      wallet.map(&:credit_card)
    end
  end
end
