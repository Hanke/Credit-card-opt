require "rails_helper"

RSpec.describe "GET /api/v1/cards", type: :request do
  it "returns 401 without a token" do
    get api_v1_cards_path, params: { q: "amex" }

    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body).to eq("errors" => [ "You must be logged in" ])
  end

  context "when authenticated" do
    let(:headers) { auth_headers(create(:user)) }

    let!(:cobalt) { create(:credit_card, :amex_cobalt) }
    let!(:td_aeroplan) { create(:credit_card, :td_aeroplan_infinite) }
    let!(:pc_mastercard) { create(:credit_card, :pc_financial_mastercard) }
    let!(:inactive_amex) { create(:credit_card, :inactive, name: "Amex Platinum", issuer: "American Express") }

    def card_names
      response.parsed_body.fetch("cards").map { |card| card["name"] }
    end

    it "searches active cards by partial name or issuer" do
      get api_v1_cards_path, params: { q: "amex" }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(card_names).to eq([ "Amex Cobalt" ])
    end

    it "returns every active card ordered by issuer then name when the query is missing" do
      get api_v1_cards_path, headers: headers

      expect(response).to have_http_status(:ok)
      expect(card_names).to eq([ "Amex Cobalt", "PC Financial World Elite Mastercard", "TD Aeroplan Visa Infinite" ])
    end

    it "ignores a non-scalar query" do
      get api_v1_cards_path, params: { q: [ "amex" ] }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(card_names.size).to eq(3)
    end

    it "renders the summary shape including the reward currency name" do
      get api_v1_cards_path, params: { q: "cobalt" }, headers: headers

      expect(response.parsed_body.fetch("cards").first).to include(
        "id" => cobalt.id,
        "name" => "Amex Cobalt",
        "issuer" => "American Express",
        "network" => "Amex",
        "annual_fee_cents" => 15_600,
        "reward_currency" => include("name" => cobalt.reward_currency.name)
      )
    end

    it "returns an empty list when nothing matches" do
      get api_v1_cards_path, params: { q: "nonexistent" }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq("cards" => [])
    end
  end
end
