# Detail shape used by the show endpoint: the summary plus notes, the full
# reward currency, and the reward rules currently in effect.
class CreditCardDetailSerializer < ApplicationSerializer
  def call
    CreditCardSerializer.call(record).merge(
      notes: record.notes,
      reward_currency: RewardCurrencySerializer.call(record.reward_currency),
      reward_rules: RewardRuleSerializer.collection(record.current_reward_rules)
    )
  end
end
