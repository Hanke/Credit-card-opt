require "rails_helper"

RSpec.describe Users::Serialize do
  describe ".call" do
    it "returns the public attributes of a user" do
      user = create(:user, email: "person@example.com")

      payload = described_class.call(user)

      expect(payload).to eq(
        id: user.id,
        email: "person@example.com",
        created_at: user.created_at.iso8601
      )
    end

    it "never exposes the password digest" do
      payload = described_class.call(create(:user))

      expect(payload.keys).not_to include(:password_digest, :password)
    end
  end
end
