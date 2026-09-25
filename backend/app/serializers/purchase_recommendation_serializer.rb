class PurchaseRecommendationSerializer < ApplicationSerializer
  def call
    {
      recommendation: record.recommendation,
      comparisons: record.comparisons,
      input: { amount: record.input.fetch(:amount).to_s, category: record.input.fetch(:category) }
    }
  end
end
