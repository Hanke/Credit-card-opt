require "rails_helper"

RSpec.describe "POST /api/v1/recommendations", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }
  let(:cobalt) { create(:credit_card, :amex_cobalt) }
  let(:aeroplan) { create(:credit_card, :td_aeroplan_infinite) }

  before do
    create(:reward_rule, credit_card: cobalt, category: "dining", earning_rate: 5.0)
  end

  it "returns the best card, the ranked comparisons, and the echoed input" do
    create(:user_card, user: user, credit_card: aeroplan)
    create(:user_card, user: user, credit_card: cobalt)

    post api_v1_recommendations_path, params: { amount: 150.00, category: "dining" }, headers: headers, as: :json

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body.keys).to contain_exactly("recommendation", "comparisons", "input")
    expect(body.fetch("input")).to eq("amount" => "150.0", "category" => "dining")
    expect(body.fetch("recommendation")).to eq(
      "credit_card_id" => cobalt.id,
      "card_name" => "Amex Cobalt",
      "issuer" => "American Express",
      "reward_currency" => "Membership Rewards",
      "cash_back" => false,
      "earning_rate" => "5.0",
      "points_earned" => "750.0",
      "estimated_value_cents" => 750,
      "rule_applied" => "Dining rule",
      "spend_cap_cents" => nil,
      "explanation" => "Amex Cobalt earns 5x Membership Rewards on dining. 150 × 5 = 750 pts ≈ $7.50"
    )
    expect(body.fetch("comparisons")).to contain_exactly(a_hash_including("credit_card_id" => aeroplan.id, "estimated_value_cents" => 225))
  end

  it "never lists the recommended card among the comparisons" do
    create(:user_card, user: user, credit_card: aeroplan)
    create(:user_card, user: user, credit_card: cobalt)

    post api_v1_recommendations_path, params: { amount: 40, category: "dining" }, headers: headers, as: :json

    body = response.parsed_body
    expect(body.fetch("comparisons").map { |c| c["credit_card_id"] }).not_to include(body.dig("recommendation", "credit_card_id"))
  end

  it "only considers the given credit_card_ids and ignores ids the user does not own" do
    create(:user_card, user: user, credit_card: aeroplan)
    create(:user_card, user: user, credit_card: cobalt)
    create(:user_card, credit_card: create(:credit_card, :pc_financial_mastercard))
    foreign = create(:user_card).credit_card

    post api_v1_recommendations_path,
         params: { amount: 150, category: "dining", credit_card_ids: [ aeroplan.id, foreign.id ] },
         headers: headers, as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig("recommendation", "credit_card_id")).to eq(aeroplan.id)
    expect(response.parsed_body.fetch("comparisons")).to eq([])
  end

  it "returns 422 when only foreign card ids are given" do
    create(:user_card, user: user, credit_card: aeroplan)
    foreign = create(:user_card).credit_card

    post api_v1_recommendations_path, params: { amount: 150, category: "dining", credit_card_ids: [ foreign.id ] }, headers: headers, as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body).to eq("errors" => [ "None of the selected cards are in your wallet" ])
  end

  it "returns 422 when the wallet is empty" do
    create(:user_card, credit_card: cobalt)

    post api_v1_recommendations_path, params: { amount: 150, category: "dining" }, headers: headers, as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body).to eq("errors" => [ "Add a card to your wallet first" ])
  end

  it "returns 422 for an unknown category" do
    create(:user_card, user: user, credit_card: cobalt)

    post api_v1_recommendations_path, params: { amount: 150, category: "crypto" }, headers: headers, as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body).to eq("errors" => [ "Category is not a supported purchase category" ])
  end

  it "returns 422 for a missing, non-positive, oversized, or non-numeric amount" do
    create(:user_card, user: user, credit_card: cobalt)

    {
      {} => "Amount can't be blank",
      { amount: 0 } => "Amount must be greater than 0",
      { amount: -1 } => "Amount must be greater than 0",
      { amount: 1_000_000.01 } => "Amount must be less than or equal to 1000000",
      { amount: "12abc" } => "Amount is not a number"
    }.each do |amount_params, message|
      post api_v1_recommendations_path, params: { category: "dining" }.merge(amount_params), headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_content), "expected #{amount_params.inspect} to be rejected"
      expect(response.parsed_body).to eq("errors" => [ message ])
    end
  end

  it "returns 422 for credit_card_ids that are not whole numbers" do
    create(:user_card, user: user, credit_card: cobalt)

    post api_v1_recommendations_path, params: { amount: 10, category: "dining", credit_card_ids: [ "abc" ] }, headers: headers, as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body).to eq("errors" => [ "Credit card ids must be whole numbers" ])
  end

  it "returns 401 without a token" do
    post api_v1_recommendations_path, params: { amount: 150, category: "dining" }, as: :json

    expect(response).to have_http_status(:unauthorized)
  end
end
