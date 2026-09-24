require "rails_helper"

RSpec.describe "GET /api/v1/auth/me", type: :request do
  let(:user) { create(:user, email: "person@example.com") }

  it "returns the current user for a valid token" do
    get api_v1_auth_me_path, headers: auth_headers(user)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq(
      "user" => { "id" => user.id, "email" => "person@example.com", "created_at" => user.created_at.iso8601 }
    )
  end

  it "accepts extra whitespace between the scheme and the token" do
    get api_v1_auth_me_path, headers: { "Authorization" => "Bearer   #{Auth::IssueToken.call(user)}  " }

    expect(response).to have_http_status(:ok)
  end

  it "returns 401 with the error shape and a WWW-Authenticate challenge when the token is missing" do
    get api_v1_auth_me_path

    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body).to eq("errors" => [ "You must be logged in" ])
    expect(response.headers["WWW-Authenticate"]).to eq('Bearer realm="api"')
  end

  it "returns 401 for a malformed token" do
    get api_v1_auth_me_path, headers: { "Authorization" => "Bearer garbage" }

    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body).to eq("errors" => [ "You must be logged in" ])
  end

  it "returns 401 for an expired token" do
    get api_v1_auth_me_path, headers: auth_headers(user, now: 8.days.ago)

    expect(response).to have_http_status(:unauthorized)
  end

  it "returns 401 when the Authorization scheme is not Bearer" do
    get api_v1_auth_me_path, headers: { "Authorization" => "Basic #{Auth::IssueToken.call(user)}" }

    expect(response).to have_http_status(:unauthorized)
  end

  it "returns 401 when the token belongs to a deleted user" do
    headers = auth_headers(user)
    user.destroy!

    get api_v1_auth_me_path, headers: headers

    expect(response).to have_http_status(:unauthorized)
  end
end
