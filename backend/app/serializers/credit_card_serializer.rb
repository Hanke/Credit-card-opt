class CreditCardSerializer < ApplicationSerializer
  def call
    {
      id: record.id,
      name: record.name,
      issuer: record.issuer,
      network: record.network,
      annual_fee_cents: record.annual_fee_cents,
      base_earn_rate: record.base_earn_rate.to_s,
      reward_currency: RewardCurrencySerializer.call(record.reward_currency).slice(:id, :name, :cash_back)
    }
  end
end
