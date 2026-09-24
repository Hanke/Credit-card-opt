require "rails_helper"

RSpec.describe "POST /api/v1/auth/signup", type: :request do
  let(:params) { { email: "new@example.com", password: "supersecret" } }

  it "creates the user and returns a token that authenticates against /auth/me" do
    expect {
      post api_v1_auth_signup_path, params: params, as: :json
    }.to change(User, :count).by(1)

    expect(response).to have_http_status(:created)

    body = response.parsed_body
    expect(body["token"]).to be_present
    expect(body["user"]).to include("id" => User.last.id, "email" => "new@example.com")
    expect(body["user"]).not_to have_key("password_digest")

    get api_v1_auth_me_path, headers: { "Authorization" => "Bearer #{body["token"]}" }

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["user"]["email"]).to eq("new@example.com")
  end

  it "returns 422 with the error shape for a duplicate email" do
    create(:user, email: "new@example.com")

    expect {
      post api_v1_auth_signup_path, params: params, as: :json
    }.not_to change(User, :count)

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body).to eq("errors" => [ "Email has already been taken" ])
  end

  it "returns 422 with the error shape for missing fields" do
    post api_v1_auth_signup_path, params: {}, as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body["errors"]).to include("Email can't be blank", "Password can't be blank")
  end

  it "returns 422 for a password shorter than 8 characters" do
    post api_v1_auth_signup_path, params: params.merge(password: "short"), as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body["errors"]).to include("Password is too short (minimum is 8 characters)")
  end

  it "returns 422 rather than 500 when credentials are not strings" do
    post api_v1_auth_signup_path, params: { email: 12345, password: true }, as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body["errors"]).to include("Email is invalid")
  end

  it "does not raise on the wrapped JSON parameter when unpermitted params are set to raise" do
    original = ActionController::Parameters.action_on_unpermitted_parameters
    ActionController::Parameters.action_on_unpermitted_parameters = :raise

    post api_v1_auth_signup_path, params: params, as: :json

    expect(response).to have_http_status(:created)
  ensure
    ActionController::Parameters.action_on_unpermitted_parameters = original
  end
end
