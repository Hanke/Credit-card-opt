module Wallet
  class ListCards
    def self.call(user:)
      new(user: user).call
    end

    def initialize(user:)
      @user = user
    end

    def call
      user.user_cards.includes(credit_card: :reward_currency).order(:added_at, :id)
    end

    private

    attr_reader :user
  end
end
