module Wallet
  class AddCard
    UNAVAILABLE_CARD_ERROR = "Credit card is not available".freeze
    ALREADY_IN_WALLET_ERROR = "Credit card is already in your wallet".freeze

    def self.call(user:, credit_card_id:)
      new(user: user, credit_card_id: credit_card_id).call
    end

    def initialize(user:, credit_card_id:)
      @user = user
      @credit_card_id = credit_card_id
    end

    def call
      card = CreditCard.active.find_by(id: credit_card_id)
      return Result.failure(UNAVAILABLE_CARD_ERROR) if card.nil?

      user_card = UserCard.new(user: user, credit_card: card)

      if user_card.save
        Result.success(user_card: user_card)
      else
        Result.failure(error_messages(user_card))
      end
    rescue ActiveRecord::RecordNotUnique
      Result.failure(ALREADY_IN_WALLET_ERROR)
    end

    private

    attr_reader :user, :credit_card_id

    def error_messages(user_card)
      return ALREADY_IN_WALLET_ERROR if user_card.errors.of_kind?(:credit_card_id, :taken)

      user_card.errors.full_messages
    end
  end
end
