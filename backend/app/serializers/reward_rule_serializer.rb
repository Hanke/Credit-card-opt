class RewardRuleSerializer < ApplicationSerializer
  def call
    {
      id: record.id,
      category: record.category,
      earning_rate: record.earning_rate.to_s,
      spend_cap_cents: record.spend_cap_cents,
      effective_from: record.effective_from.iso8601,
      effective_to: record.effective_to&.iso8601,
      notes: record.notes
    }
  end
end
