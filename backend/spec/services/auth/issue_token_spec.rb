require "rails_helper"

RSpec.describe Auth::IssueToken do
  let(:user) { create(:user) }
  let(:secret) { Rails.application.secret_key_base }

  describe ".call" do
    it "returns a signed JWT string" do
      token = described_class.call(user)

      expect(token).to be_a(String)
      expect(token.split(".").size).to eq(3)
    end

    it "encodes the user id as sub with a 7 day expiry" do
      now = Time.zone.parse("2026-09-24 12:00:00 UTC")
      token = described_class.call(user, now: now)

      payload, header = JWT.decode(token, secret, true, algorithm: described_class::ALGORITHM)

      expect(payload["sub"]).to eq(user.id.to_s)
      expect(payload["iat"]).to eq(now.to_i)
      expect(payload["exp"]).to eq((now + 7.days).to_i)
      expect(header["alg"]).to eq(described_class::ALGORITHM)
    end

    it "is signed with the application secret" do
      token = described_class.call(user)

      expect {
        JWT.decode(token, "not-the-secret", true, algorithm: described_class::ALGORITHM)
      }.to raise_error(JWT::VerificationError)
    end
  end
end
