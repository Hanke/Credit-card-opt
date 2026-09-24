require "rails_helper"

RSpec.describe "GET /api/v1/cards/:id", type: :request do
  let(:headers) { auth_headers(create(:user)) }

  it "returns the card detail with its reward currency and current reward rules" do
    card = create(:credit_card, :amex_cobalt)
    rule = create(:reward_rule, credit_card: card)

    get api_v1_card_path(card), headers: headers

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch("card")).to include(
      "id" => card.id,
      "name" => "Amex Cobalt",
      "reward_currency" => include("name" => card.reward_currency.name),
      "reward_rules" => [ include("id" => rule.id) ]
    )
  end

  it "returns 404 for an unknown id" do
    get api_v1_card_path(0), headers: headers

    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body).to eq("errors" => [ "Not found" ])
  end

  it "returns 401 without a token" do
    get api_v1_card_path(0)

    expect(response).to have_http_status(:unauthorized)
  end
end
