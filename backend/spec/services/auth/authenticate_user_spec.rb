require "rails_helper"

RSpec.describe Auth::AuthenticateUser do
  let!(:user) { create(:user, email: "person@example.com", password: "correct-horse") }

  describe ".call" do
    it "returns the user and a token for valid credentials" do
      result = described_class.call(email: "person@example.com", password: "correct-horse")

      expect(result).to be_success
      expect(result.user).to eq(user)
      expect(Auth::DecodeToken.call(result.token)).to eq(user)
    end

    it "matches the email case-insensitively and ignores surrounding whitespace" do
      result = described_class.call(email: "  Person@Example.COM ", password: "correct-horse")

      expect(result.user).to eq(user)
    end

    it "fails for a wrong password" do
      result = described_class.call(email: "person@example.com", password: "wrong")

      expect(result).not_to be_success
      expect(result.user).to be_nil
      expect(result.token).to be_nil
      expect(result.errors).to eq([ "Invalid email or password" ])
    end

    it "fails for an unknown email with the same error as a wrong password" do
      result = described_class.call(email: "nobody@example.com", password: "correct-horse")

      expect(result.errors).to eq([ "Invalid email or password" ])
    end

    it "fails for blank credentials" do
      expect(described_class.call(email: "", password: "correct-horse")).not_to be_success
      expect(described_class.call(email: "person@example.com", password: "")).not_to be_success
      expect(described_class.call(email: nil, password: nil)).not_to be_success
    end
  end
end
