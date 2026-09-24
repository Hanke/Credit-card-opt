require "rails_helper"

RSpec.describe "db/seeds" do
  def load_seeds
    silence_stream($stdout) { Rails.application.load_seed }
  end

  def silence_stream(stream)
    original = stream.dup
    stream.reopen(File::NULL)
    yield
  ensure
    stream.reopen(original)
  end

  before { load_seeds }

  it "seeds a broad catalogue of active Canadian cards" do
    expect(CreditCard.active.count).to be >= 25
    expect(CreditCard.active.count).to eq(CreditCard.count)
    expect(CreditCard.active.count).to be <= Cards::Search::MAX_RESULTS
  end

  it "gives every card a currency, a base rate and at least one reward rule" do
    CreditCard.includes(:reward_currency, :reward_rules).find_each do |card|
      expect(card.reward_currency).to be_present, "#{card.name} has no reward currency"
      expect(card.base_earn_rate).to be >= 0
      expect(card.reward_rules).not_to be_empty, "#{card.name} has no reward rules"
    end
  end

  it "gives every rule a known category and an effective_from date" do
    RewardRule.find_each do |rule|
      expect(PurchaseCategories.valid?(rule.category)).to be(true), "unknown category #{rule.category}"
      expect(rule.effective_from).to be_present
    end
  end

  it "does not seed the same category twice for one card and date" do
    duplicates = RewardRule.group(:credit_card_id, :category, :effective_from).having("count(*) > 1").count

    expect(duplicates).to be_empty
  end

  it "is idempotent when run again" do
    expect { load_seeds }.not_to change {
      [ RewardCurrency.count, CreditCard.count, RewardRule.count ]
    }
  end

  it "refreshes existing rows instead of duplicating them" do
    card = CreditCard.find_by!(name: "Amex Cobalt")
    card.update!(annual_fee_cents: 1, notes: "stale")
    card.reward_rules.for_category("dining").update_all(earning_rate: 1.0)

    load_seeds

    card.reload
    expect(card.annual_fee_cents).to eq(19_188)
    expect(card.notes).not_to eq("stale")
    expect(card.reward_rules.for_category("dining").pluck(:earning_rate)).to eq([ 5.0 ])
  end

  it "models cash-back cards as percentages worth one cent per point" do
    cash_back = RewardCurrency.find_by!(name: "Cash Back")
    card = CreditCard.find_by!(name: "Amex SimplyCash Preferred Card")
    rule = card.reward_rules.for_category("gas").current.first!

    expect(cash_back).to be_cash_back
    expect(cash_back.cents_per_point).to eq(1.0)
    expect(card.reward_currency).to eq(cash_back)
    expect(150 * rule.earning_rate * cash_back.cents_per_point).to eq(600)
  end

  it "values Amex Cobalt dining at 750 points, about $7.50, on a $150 purchase" do
    card = CreditCard.find_by!(name: "Amex Cobalt")
    rule = card.reward_rules.for_category("dining").current.first!

    points = 150 * rule.earning_rate
    expect(points).to eq(750)
    expect(points * card.reward_currency.cents_per_point).to eq(750)
  end

  it "seeds the expected valuations for the major points currencies" do
    valuations = RewardCurrency.where(name: [ "Membership Rewards", "Aeroplan", "Avion", "Scene+",
                                              "BMO Rewards", "CIBC Aventura", "PC Optimum" ])
                               .pluck(:name, :cents_per_point).to_h

    expect(valuations).to eq(
      "Membership Rewards" => 1.0, "Aeroplan" => 1.5, "Avion" => 1.0, "Scene+" => 1.0,
      "BMO Rewards" => 0.7, "CIBC Aventura" => 1.0, "PC Optimum" => 0.1
    )
    expect(RewardCurrency.where(name: valuations.keys).where(description: [ nil, "" ])).to be_empty
  end
end
