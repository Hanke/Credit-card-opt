require "rails_helper"

RSpec.describe Auth::DecodeToken do
  let(:user) { create(:user) }
  let(:secret) { Rails.application.secret_key_base }
  let(:algorithm) { Auth::IssueToken::ALGORITHM }

  describe ".call" do
    it "round-trips a token issued for a user" do
      token = Auth::IssueToken.call(user)

      expect(described_class.call(token)).to eq(user)
    end

    it "returns the user right up until expiry" do
      token = Auth::IssueToken.call(user, now: 7.days.ago + 1.minute)

      expect(described_class.call(token)).to eq(user)
    end

    it "returns nil for an expired token" do
      token = Auth::IssueToken.call(user, now: 8.days.ago)

      expect(described_class.call(token)).to be_nil
    end

    it "returns nil for a tampered payload" do
      other_user = create(:user)
      header, _payload, signature = Auth::IssueToken.call(user).split(".")
      forged = Base64.urlsafe_encode64({ sub: other_user.id.to_s, exp: 1.day.from_now.to_i }.to_json, padding: false)

      expect(described_class.call([ header, forged, signature ].join("."))).to be_nil
    end

    it "returns nil for a token signed with a different secret" do
      token = JWT.encode({ sub: user.id.to_s, exp: 1.day.from_now.to_i }, "wrong-secret", algorithm)

      expect(described_class.call(token)).to be_nil
    end

    it "returns nil for an unsigned token" do
      token = JWT.encode({ sub: user.id.to_s, exp: 1.day.from_now.to_i }, nil, "none")

      expect(described_class.call(token)).to be_nil
    end

    it "returns nil when the token has no sub claim" do
      token = JWT.encode({ exp: 1.day.from_now.to_i }, secret, algorithm)

      expect(described_class.call(token)).to be_nil
    end

    it "returns nil when the user no longer exists" do
      token = Auth::IssueToken.call(user)
      user.destroy!

      expect(described_class.call(token)).to be_nil
    end

    it "returns nil for malformed input" do
      expect(described_class.call("not.a.jwt")).to be_nil
      expect(described_class.call("garbage")).to be_nil
      expect(described_class.call("")).to be_nil
      expect(described_class.call(nil)).to be_nil
    end
  end
end
