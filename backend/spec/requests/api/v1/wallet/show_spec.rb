require "rails_helper"

RSpec.describe "GET /api/v1/wallet", type: :request do
  let(:user) { create(:user) }

  it "returns only the current user's cards, oldest first, with added_at" do
    card = create(:credit_card, :amex_cobalt)
    newer = create(:user_card, user: user, added_at: 1.day.ago)
    older = create(:user_card, user: user, credit_card: card, added_at: 3.days.ago)
    create(:user_card)

    get api_v1_wallet_path, headers: auth_headers(user)

    expect(response).to have_http_status(:ok)
    cards = response.parsed_body.fetch("cards")
    expect(cards.map { |c| c["id"] }).to eq([ card.id, newer.credit_card_id ])
    expect(cards.first).to include(
      "id" => card.id,
      "name" => "Amex Cobalt",
      "active" => true,
      "added_at" => older.added_at.iso8601,
      "reward_currency" => { "id" => card.reward_currency.id, "name" => card.reward_currency.name }
    )
  end

  it "still lists a card that was deactivated after being added, flagged inactive" do
    entry = create(:user_card, user: user)
    entry.credit_card.update!(active: false)

    get api_v1_wallet_path, headers: auth_headers(user)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch("cards")).to contain_exactly(a_hash_including("id" => entry.credit_card_id, "active" => false))
  end

  it "returns an empty list for a user with no cards" do
    get api_v1_wallet_path, headers: auth_headers(user)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq("cards" => [])
  end

  it "cannot see another user's wallet" do
    other = create(:user)
    create(:user_card, user: other)

    get api_v1_wallet_path, headers: auth_headers(user)

    expect(response.parsed_body).to eq("cards" => [])
  end

  it "returns 401 without a token" do
    get api_v1_wallet_path

    expect(response).to have_http_status(:unauthorized)
  end
end
