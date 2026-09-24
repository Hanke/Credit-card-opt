require "rails_helper"

RSpec.describe CreditCard, type: :model do
  subject { build(:credit_card) }

  describe "associations" do
    it { is_expected.to belong_to(:reward_currency) }
    it { is_expected.to have_many(:reward_rules).dependent(:destroy) }
    it { is_expected.to have_many(:user_cards).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:user_cards) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:issuer) }
    it { is_expected.to validate_numericality_of(:annual_fee_cents).only_integer.is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:base_earn_rate).is_greater_than_or_equal_to(0) }

    it "rejects a nil active flag" do
      card = build(:credit_card, active: nil)

      expect(card).not_to be_valid
      expect(card.errors[:active]).to be_present
    end
  end

  describe "scopes" do
    let!(:cobalt) { create(:credit_card, :amex_cobalt) }
    let!(:td_aeroplan) { create(:credit_card, :td_aeroplan_infinite) }
    let!(:pc_mastercard) { create(:credit_card, :pc_financial_mastercard, :inactive) }

    describe ".active" do
      it "returns only active cards" do
        expect(described_class.active).to contain_exactly(cobalt, td_aeroplan)
      end
    end

    describe ".search" do
      it "matches name case-insensitively" do
        expect(described_class.search("cobalt")).to contain_exactly(cobalt)
      end

      it "matches issuer case-insensitively" do
        expect(described_class.search("td")).to contain_exactly(td_aeroplan)
      end

      it "matches partial terms across name and issuer" do
        expect(described_class.search("master")).to contain_exactly(pc_mastercard)
        expect(described_class.search("american")).to contain_exactly(cobalt)
      end

      it "returns everything for a blank query" do
        expect(described_class.search("")).to contain_exactly(cobalt, td_aeroplan, pc_mastercard)
        expect(described_class.search(nil)).to contain_exactly(cobalt, td_aeroplan, pc_mastercard)
      end

      it "treats LIKE wildcards literally" do
        expect(described_class.search("%")).to be_empty
        expect(described_class.search("_")).to be_empty
      end

      it "chains with other scopes" do
        expect(described_class.active.search("pc")).to be_empty
        expect(described_class.active.search("amex")).to contain_exactly(cobalt)
      end
    end
  end

  it "destroys its reward rules and user cards when destroyed" do
    card = create(:credit_card)
    create(:reward_rule, credit_card: card)
    create(:user_card, credit_card: card)

    expect { card.destroy! }
      .to change(RewardRule, :count).by(-1)
      .and change(UserCard, :count).by(-1)
  end
end
