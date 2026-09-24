require "rails_helper"

RSpec.describe RewardRule, type: :model do
  subject { build(:reward_rule) }

  describe "associations" do
    it { is_expected.to belong_to(:credit_card) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_inclusion_of(:category).in_array(PurchaseCategories::ALL) }
    it { is_expected.to validate_presence_of(:earning_rate) }
    it { is_expected.to validate_numericality_of(:earning_rate).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:spend_cap_cents).only_integer.is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to validate_presence_of(:effective_from) }

    it "allows a nil effective_to" do
      expect(build(:reward_rule, effective_to: nil)).to be_valid
    end

    it "allows effective_to equal to effective_from" do
      rule = build(:reward_rule, effective_from: Date.new(2024, 1, 1), effective_to: Date.new(2024, 1, 1))

      expect(rule).to be_valid
    end

    it "rejects effective_to before effective_from" do
      rule = build(:reward_rule, effective_from: Date.new(2024, 1, 2), effective_to: Date.new(2024, 1, 1))

      expect(rule).not_to be_valid
      expect(rule.errors[:effective_to]).to be_present
    end

    it "rejects unknown categories" do
      rule = build(:reward_rule, category: "crypto")

      expect(rule).not_to be_valid
      expect(rule.errors[:category]).to include("is not included in the list")
    end

    it "rejects negative earning rates" do
      expect(build(:reward_rule, earning_rate: -1)).not_to be_valid
    end
  end

  describe "scopes" do
    let(:card) { create(:credit_card) }
    let(:today) { Date.new(2026, 9, 24) }

    let!(:current_dining) do
      create(:reward_rule, credit_card: card, category: "dining",
                           effective_from: today - 30, effective_to: nil)
    end
    let!(:bounded_dining) do
      create(:reward_rule, credit_card: card, category: "dining",
                           effective_from: today - 10, effective_to: today + 10)
    end
    let!(:expired_dining) do
      create(:reward_rule, credit_card: card, category: "dining",
                           effective_from: today - 100, effective_to: today - 1)
    end
    let!(:future_dining) do
      create(:reward_rule, credit_card: card, category: "dining",
                           effective_from: today + 1, effective_to: nil)
    end
    let!(:current_groceries) do
      create(:reward_rule, credit_card: card, category: "groceries",
                           effective_from: today - 30, effective_to: nil)
    end

    describe ".for_category" do
      it "returns rules for the given category only" do
        expect(described_class.for_category("groceries")).to contain_exactly(current_groceries)
      end

      it "accepts a symbol" do
        expect(described_class.for_category(:groceries)).to contain_exactly(current_groceries)
      end
    end

    describe ".current" do
      it "is effective_on today" do
        travel_to today do
          expect(described_class.current).to contain_exactly(current_dining, bounded_dining, current_groceries)
        end
      end
    end

    describe ".effective_on" do
      it "returns open-ended and bounded rules that cover the date" do
        expect(described_class.effective_on(today))
          .to contain_exactly(current_dining, bounded_dining, current_groceries)
      end

      it "includes rules whose window starts or ends exactly on the date" do
        expect(described_class.effective_on(today - 10)).to include(bounded_dining)
        expect(described_class.effective_on(today + 10)).to include(bounded_dining)
        expect(described_class.effective_on(today - 1)).to include(expired_dining)
      end

      it "excludes expired and future rules" do
        result = described_class.effective_on(today)

        expect(result).not_to include(expired_dining)
        expect(result).not_to include(future_dining)
      end
    end

    it "combines for_category and effective_on to return only current rules for a category" do
      expect(described_class.for_category("dining").effective_on(today))
        .to contain_exactly(current_dining, bounded_dining)
    end
  end
end
