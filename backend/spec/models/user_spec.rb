require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:user_cards).dependent(:destroy) }
    it { is_expected.to have_many(:credit_cards).through(:user_cards) }

    it "exposes credit cards through user cards" do
      user = create(:user)
      card = create(:credit_card)
      create(:user_card, user: user, credit_card: card)

      expect(user.credit_cards).to contain_exactly(card)
    end
  end

  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to have_secure_password }

    it "accepts well-formed emails" do
      expect(build(:user, email: "first.last+tag@example.co.uk")).to be_valid
    end

    it "rejects malformed emails" do
      %w[plainaddress missing-at.com @no-local.com spaces\ in@example.com].each do |bad|
        user = build(:user, email: bad)

        expect(user).not_to be_valid, "expected #{bad.inspect} to be invalid"
        expect(user.errors[:email]).to include("is invalid")
      end
    end

    it "rejects duplicate emails regardless of case" do
      existing = create(:user)
      dup = build(:user, email: existing.email.upcase)

      expect(dup).not_to be_valid
      expect(dup.errors[:email]).to include("has already been taken")
      expect { dup.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "requires passwords to be at least 8 characters" do
      user = build(:user, password: "short")

      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 8 characters)")
      expect(build(:user, password: "12345678")).to be_valid
    end

    it "does not re-validate password length when the password is not being changed" do
      user = create(:user)
      reloaded = User.find(user.id)

      expect(reloaded).to be_valid
    end

    it "requires password confirmation to match when provided" do
      user = build(:user, password: "supersecret", password_confirmation: "different")

      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end
  end

  describe "database constraints" do
    it "enforces email uniqueness at the database level" do
      existing = create(:user)
      dup = User.new(email: existing.email, password_digest: "x")

      expect { dup.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "email normalization" do
    it "downcases and strips whitespace" do
      user = create(:user, email: "  New.Person@Example.COM  ")

      expect(user.email).to eq("new.person@example.com")
    end
  end

  describe "authentication" do
    it "creates a user with a valid email and password" do
      user = User.create!(email: "new@example.com", password: "supersecret")

      expect(user).to be_persisted
      expect(user.authenticate("supersecret")).to eq(user)
      expect(user.authenticate("wrong")).to be(false)
    end
  end
end
