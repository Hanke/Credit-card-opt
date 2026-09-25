require "rails_helper"

RSpec.describe PurchaseRecommendationSerializer do
  describe ".call" do
    it "returns the recommendation, comparisons, and the echoed input with a string amount" do
      result = Recommendations::Result.success(
        recommendation: { credit_card_id: 1 },
        comparisons: [ { credit_card_id: 2 } ],
        input: { amount: BigDecimal("150"), category: "dining" }
      )

      expect(described_class.call(result)).to eq(
        recommendation: { credit_card_id: 1 },
        comparisons: [ { credit_card_id: 2 } ],
        input: { amount: "150.0", category: "dining" }
      )
    end
  end
end
