module Cards
  # Loads an active card with its currency and current reward rules.
  # Raises ActiveRecord::RecordNotFound for unknown or inactive ids.
  class Find
    def self.call(id:)
      new(id: id).call
    end

    def initialize(id:)
      @id = id
    end

    def call
      CreditCard.active.includes(:reward_currency, :current_reward_rules).find(id)
    end

    private

    attr_reader :id
  end
end
