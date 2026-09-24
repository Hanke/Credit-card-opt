require "rails_helper"

RSpec.describe "DELETE /api/v1/wallet/:credit_card_id", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }

  it "removes the card from the current user's wallet" do
    user_card = create(:user_card, user: user)

    delete api_v1_wallet_card_path(user_card.credit_card_id), headers: headers

    expect(response).to have_http_status(:no_content)
    expect(response.body).to be_empty
    expect(user.user_cards).to be_empty
  end

  it "returns 404 when the card is not in the wallet" do
    card = create(:credit_card)

    delete api_v1_wallet_card_path(card), headers: headers

    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body).to eq("errors" => [ "Not found" ])
  end

  it "returns 404 and leaves the entry alone when the card is in another user's wallet" do
    other_entry = create(:user_card)

    delete api_v1_wallet_card_path(other_entry.credit_card_id), headers: headers

    expect(response).to have_http_status(:not_found)
    expect(other_entry.reload).to be_persisted
  end

  it "returns 401 without a token" do
    delete api_v1_wallet_card_path(0)

    expect(response).to have_http_status(:unauthorized)
  end
end
