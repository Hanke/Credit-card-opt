require "rails_helper"

RSpec.describe Auth::Result do
  it "builds a successful result with no errors" do
    user = build(:user)

    result = described_class.success(user: user, token: "abc")

    expect(result).to be_success
    expect(result.user).to eq(user)
    expect(result.token).to eq("abc")
    expect(result.errors).to eq([])
  end

  it "builds a failed result from a single error or a list" do
    expect(described_class.failure("boom")).to have_attributes(success?: false, user: nil, token: nil, errors: [ "boom" ])
    expect(described_class.failure(%w[a b]).errors).to eq(%w[a b])
  end
end
