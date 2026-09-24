require "rails_helper"

RSpec.describe "DELETE /api/v1/auth/logout", type: :request do
  let(:user) { create(:user) }

  it "returns 204 for an authenticated request" do
    delete api_v1_auth_logout_path, headers: { "Authorization" => "Bearer #{Auth::IssueToken.call(user)}" }

    expect(response).to have_http_status(:no_content)
    expect(response.body).to be_empty
  end

  it "is idempotent: returns 204 for an expired token" do
    delete api_v1_auth_logout_path, headers: { "Authorization" => "Bearer #{Auth::IssueToken.call(user, now: 8.days.ago)}" }

    expect(response).to have_http_status(:no_content)
  end

  it "is idempotent: returns 204 when no token is sent" do
    delete api_v1_auth_logout_path

    expect(response).to have_http_status(:no_content)
  end
end
