class RewardCurrencySerializer < ApplicationSerializer
  def call
    {
      id: record.id,
      name: record.name,
      cents_per_point: record.cents_per_point.to_s,
      description: record.description
    }
  end
end
