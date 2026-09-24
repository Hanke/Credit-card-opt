module Wallet
  Result = Struct.new(:user_card, :errors, keyword_init: true) do
    def self.success(user_card:)
      new(user_card: user_card, errors: [])
    end

    def self.failure(errors)
      new(user_card: nil, errors: Array(errors))
    end

    def success? = errors.empty?
  end
end
