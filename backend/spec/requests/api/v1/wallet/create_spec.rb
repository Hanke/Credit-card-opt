require "rails_helper"

RSpec.describe "POST /api/v1/wallet", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }
  let(:card) { create(:credit_card, :amex_cobalt) }

  it "adds the card to the current user's wallet" do
    post api_v1_wallet_path, params: { credit_card_id: card.id }, headers: headers, as: :json

    expect(response).to have_http_status(:created)
    expect(response.parsed_body.fetch("card")).to include("id" => card.id, "name" => "Amex Cobalt")
    expect(response.parsed_body.dig("card", "added_at")).to be_present
    expect(user.credit_cards).to contain_exactly(card)
  end

  it "returns 422 when the card is already in the wallet" do
    create(:user_card, user: user, credit_card: card)

    post api_v1_wallet_path, params: { credit_card_id: card.id }, headers: headers, as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body).to eq("errors" => [ "Credit card is already in your wallet" ])
    expect(user.user_cards.count).to eq(1)
  end

  it "returns 422 for an inactive card" do
    inactive = create(:credit_card, :inactive)

    post api_v1_wallet_path, params: { credit_card_id: inactive.id }, headers: headers, as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body).to eq("errors" => [ "Credit card is not available" ])
  end

  it "returns 422 for an unknown or missing card id" do
    post api_v1_wallet_path, params: { credit_card_id: 0 }, headers: headers, as: :json
    expect(response).to have_http_status(:unprocessable_content)

    post api_v1_wallet_path, params: {}, headers: headers, as: :json
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "adds to the current user's wallet even if another user's id is supplied" do
    other = create(:user)

    post api_v1_wallet_path, params: { credit_card_id: card.id, user_id: other.id }, headers: headers, as: :json

    expect(response).to have_http_status(:created)
    expect(user.credit_cards).to contain_exactly(card)
    expect(other.credit_cards).to be_empty
  end

  it "returns 401 without a token" do
    post api_v1_wallet_path, params: { credit_card_id: card.id }, as: :json

    expect(response).to have_http_status(:unauthorized)
  end
end
