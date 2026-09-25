require "rails_helper"

RSpec.describe ServiceResult do
  let(:result_class) { described_class.with(:thing, :other) }

  it "builds a successful result carrying the payload and no errors" do
    result = result_class.success(thing: 1, other: "x")

    expect(result).to be_success
    expect(result).to have_attributes(thing: 1, other: "x", errors: [])
  end

  it "builds a failed result with nil payload fields from a single error or a list" do
    expect(result_class.failure("boom")).to have_attributes(success?: false, thing: nil, other: nil, errors: [ "boom" ])
    expect(result_class.failure(%w[a b]).errors).to eq(%w[a b])
  end

  it "rejects payload keys it was not declared with" do
    expect { result_class.success(unknown: 1) }.to raise_error(ArgumentError)
  end
end
