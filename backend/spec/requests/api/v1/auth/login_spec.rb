require "rails_helper"

RSpec.describe "POST /api/v1/auth/login", type: :request do
  let!(:user) { create(:user, email: "person@example.com", password: "correct-horse") }

  it "returns 200 with a token and the user for valid credentials" do
    post api_v1_auth_login_path, params: { email: "person@example.com", password: "correct-horse" }, as: :json

    expect(response).to have_http_status(:ok)

    body = response.parsed_body
    expect(body["user"]).to include("id" => user.id, "email" => "person@example.com")
    expect(Auth::DecodeToken.call(body["token"])).to eq(user)
  end

  it "returns 401 with the error shape for a wrong password" do
    post api_v1_auth_login_path, params: { email: "person@example.com", password: "wrong" }, as: :json

    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body).to eq("errors" => [ "Invalid email or password" ])
  end

  it "returns 401 for an unknown email" do
    post api_v1_auth_login_path, params: { email: "nobody@example.com", password: "correct-horse" }, as: :json

    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body).to eq("errors" => [ "Invalid email or password" ])
  end

  it "returns 401 for missing credentials" do
    post api_v1_auth_login_path, params: {}, as: :json

    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body["errors"]).to be_present
  end
end
