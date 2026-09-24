require "rails_helper"

RSpec.describe PurchaseCategories do
  it "lists the canonical categories" do
    expect(described_class::ALL).to eq(
      %w[groceries dining gas travel hotels flights transit entertainment drugstore general other]
    )
  end

  it "is frozen" do
    expect(described_class::ALL).to be_frozen
  end

  describe ".valid?" do
    it "accepts known categories as strings or symbols" do
      expect(described_class.valid?("dining")).to be(true)
      expect(described_class.valid?(:groceries)).to be(true)
    end

    it "rejects unknown categories" do
      expect(described_class.valid?("crypto")).to be(false)
      expect(described_class.valid?(nil)).to be(false)
    end
  end
end
