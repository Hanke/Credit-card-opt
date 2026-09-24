require "rails_helper"

RSpec.describe Auth::RegisterUser do
  describe ".call" do
    it "creates the user and returns a token for them" do
      result = described_class.call(email: "New@Example.com", password: "supersecret")

      expect(result).to be_success
      expect(result.errors).to be_empty
      expect(result.user).to be_persisted
      expect(result.user.email).to eq("new@example.com")
      expect(Auth::DecodeToken.call(result.token)).to eq(result.user)
    end

    it "returns validation errors for a duplicate email" do
      existing = create(:user)

      result = described_class.call(email: existing.email.upcase, password: "supersecret")

      expect(result).not_to be_success
      expect(result.user).to be_nil
      expect(result.token).to be_nil
      expect(result.errors).to include("Email has already been taken")
    end

    it "returns the duplicate email error when the unique index rejects a concurrent insert" do
      allow_any_instance_of(User).to receive(:save).and_raise(ActiveRecord::RecordNotUnique, "duplicate key")

      result = described_class.call(email: "racer@example.com", password: "supersecret")

      expect(result).not_to be_success
      expect(result.errors).to eq([ "Email has already been taken" ])
    end

    it "returns validation errors for a missing email or password" do
      result = described_class.call(email: "", password: "")

      expect(result).not_to be_success
      expect(result.errors).to include("Email can't be blank", "Password can't be blank")
    end

    it "returns validation errors for a malformed email" do
      result = described_class.call(email: "not-an-email", password: "supersecret")

      expect(result).not_to be_success
      expect(result.errors).to include("Email is invalid")
    end

    it "returns validation errors for a short password" do
      result = described_class.call(email: "new@example.com", password: "short")

      expect(result).not_to be_success
      expect(result.errors).to include("Password is too short (minimum is 8 characters)")
    end

    it "does not create a user when registration fails" do
      expect {
        described_class.call(email: "bad", password: "")
      }.not_to change(User, :count)
    end
  end
end
