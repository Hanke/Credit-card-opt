require "rails_helper"

RSpec.describe Recommendations::PurchaseParams do
  it "is valid for a positive amount and a known category" do
    purchase = described_class.new(amount: "150.00", category: "dining")

    expect(purchase).to be_valid
    expect(purchase.amount).to eq(BigDecimal("150"))
    expect(purchase.credit_card_ids).to be_nil
  end

  it "accepts an amount of exactly one million" do
    expect(described_class.new(amount: 1_000_000, category: "dining")).to be_valid
  end

  it "rejects a missing, zero, negative, or oversized amount" do
    expect(amount_errors(nil)).to eq([ "Amount can't be blank" ])
    expect(amount_errors("")).to eq([ "Amount can't be blank" ])
    expect(amount_errors(0)).to eq([ "Amount must be greater than 0" ])
    expect(amount_errors(-5)).to eq([ "Amount must be greater than 0" ])
    expect(amount_errors(1_000_000.01)).to eq([ "Amount must be less than or equal to 1000000" ])
  end

  it "rejects an amount that is not purely numeric instead of coercing it" do
    [ "abc", "12abc", "150 dollars", "$150", "1e3xyz", "15o" ].each do |amount|
      expect(amount_errors(amount)).to eq([ "Amount is not a number" ]), "expected #{amount.inspect} to be rejected"
    end
  end

  it "rejects a missing or unknown category" do
    expect(category_errors(nil)).to eq([ "Category can't be blank" ])
    expect(category_errors("crypto")).to eq([ "Category is not a supported purchase category" ])
  end

  it "parses credit_card_ids as base-ten integers and treats a blank list as absent" do
    expect(described_class.new(credit_card_ids: [ "1", 2, "010" ]).credit_card_ids).to eq([ 1, 2, 10 ])
    expect(described_class.new(credit_card_ids: []).credit_card_ids).to be_nil
    expect(described_class.new(credit_card_ids: nil).credit_card_ids).to be_nil
  end

  it "rejects credit_card_ids that are not whole numbers" do
    purchase = described_class.new(amount: 10, category: "dining", credit_card_ids: [ "1", "x", "0x1A", "1.5" ])

    expect(purchase).not_to be_valid
    expect(purchase.errors.full_messages).to eq([ "Credit card ids must be whole numbers" ])
  end

  def amount_errors(amount)
    purchase = described_class.new(amount: amount, category: "dining")
    purchase.validate
    purchase.errors.full_messages_for(:amount)
  end

  def category_errors(category)
    purchase = described_class.new(amount: 10, category: category)
    purchase.validate
    purchase.errors.full_messages_for(:category)
  end
end
