require "rails_helper"

RSpec.describe Recommendations::Result do
  it "carries the recommendation, comparisons, and input on success" do
    result = described_class.success(recommendation: { card_name: "A" }, comparisons: [], input: { amount: 1, category: "dining" })

    expect(result).to be_success
    expect(result).to have_attributes(recommendation: { card_name: "A" }, comparisons: [], input: { amount: 1, category: "dining" }, errors: [])
  end

  it "carries only errors on failure" do
    expect(described_class.failure("boom")).to have_attributes(success?: false, recommendation: nil, comparisons: nil, input: nil, errors: [ "boom" ])
  end
end
