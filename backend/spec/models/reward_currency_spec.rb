require "rails_helper"

RSpec.describe RewardCurrency, type: :model do
  subject { build(:reward_currency) }

  describe "associations" do
    it { is_expected.to have_many(:credit_cards).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_presence_of(:cents_per_point) }
    it { is_expected.to validate_numericality_of(:cents_per_point).is_greater_than_or_equal_to(0) }
  end

  describe "cents_per_point unit" do
    it "stores the value of one point in cents so points * cents_per_point yields cents" do
      aeroplan = create(:reward_currency, :aeroplan)
      pc_optimum = create(:reward_currency, :pc_optimum)

      expect(750 * aeroplan.cents_per_point).to eq(1125)
      expect(10_000 * pc_optimum.cents_per_point).to eq(1000)
    end
  end

  describe "database constraints" do
    it "enforces case-insensitive name uniqueness at the database level" do
      create(:reward_currency, name: "Aeroplan")
      dup = described_class.new(name: "AEROPLAN", cents_per_point: 1.0)

      expect { dup.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  it "cannot be destroyed while credit cards reference it" do
    currency = create(:reward_currency)
    create(:credit_card, reward_currency: currency)

    expect(currency.destroy).to be(false)
    expect(currency.errors[:base]).to be_present
  end
end
