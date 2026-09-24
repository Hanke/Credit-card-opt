require "rails_helper"

RSpec.describe UserCard, type: :model do
  subject { build(:user_card) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:credit_card) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:added_at) }

    it "rejects the same card being added to a user twice" do
      existing = create(:user_card)
      dup = build(:user_card, user: existing.user, credit_card: existing.credit_card)

      expect(dup).not_to be_valid
      expect(dup.errors[:credit_card_id]).to include("has already been taken")
    end

    it "allows the same card for different users" do
      existing = create(:user_card)

      expect(build(:user_card, credit_card: existing.credit_card)).to be_valid
    end
  end

  describe "database constraints" do
    it "enforces user/card uniqueness at the database level" do
      existing = create(:user_card)
      dup = described_class.new(user: existing.user, credit_card: existing.credit_card, added_at: Time.current)

      expect { dup.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "defaults added_at at the database level for writes that bypass the model" do
      user = create(:user)
      card = create(:credit_card)

      described_class.insert_all([ { user_id: user.id, credit_card_id: card.id } ])

      expect(described_class.find_by!(user: user, credit_card: card).added_at).to be_within(5.seconds).of(Time.current)
    end
  end

  it "defaults added_at to now" do
    user_card = described_class.new

    expect(user_card.added_at).to be_within(1.second).of(Time.current)
  end
end
