require "rails_helper"

RSpec.describe Wallet::Result do
  it "builds a successful result with no errors" do
    user_card = build(:user_card)

    result = described_class.success(user_card: user_card)

    expect(result).to be_success
    expect(result.user_card).to eq(user_card)
    expect(result.errors).to eq([])
  end

  it "builds a failed result from a single error or a list" do
    expect(described_class.failure("boom")).to have_attributes(success?: false, user_card: nil, errors: [ "boom" ])
    expect(described_class.failure(%w[a b]).errors).to eq(%w[a b])
  end
end
