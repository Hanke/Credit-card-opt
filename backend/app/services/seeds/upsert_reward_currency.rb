module Seeds
  class UpsertRewardCurrency
    def self.call(name:, cents_per_point:, description: nil)
      new(name: name, cents_per_point: cents_per_point, description: description).call
    end

    def initialize(name:, cents_per_point:, description: nil)
      @name = name
      @cents_per_point = cents_per_point
      @description = description
    end

    def call
      currency = RewardCurrency.find_or_initialize_by(name: name)
      currency.assign_attributes(cents_per_point: cents_per_point, description: description)
      currency.save!
      currency
    end

    private

    attr_reader :name, :cents_per_point, :description
  end
end
