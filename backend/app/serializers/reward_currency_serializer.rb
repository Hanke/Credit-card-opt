class RewardCurrencySerializer < ApplicationSerializer
  def call
    {
      id: record.id,
      name: record.name,
      cash_back: record.cash_back?,
      cents_per_point: record.cents_per_point.to_s,
      description: record.description
    }
  end
end
