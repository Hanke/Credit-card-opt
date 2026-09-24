module Wallet
  class RemoveCard
    def self.call(user:, credit_card_id:)
      new(user: user, credit_card_id: credit_card_id).call
    end

    def initialize(user:, credit_card_id:)
      @user = user
      @credit_card_id = credit_card_id
    end

    def call
      user.user_cards.find_by!(credit_card_id: credit_card_id).tap(&:destroy!)
    end

    private

    attr_reader :user, :credit_card_id
  end
end
