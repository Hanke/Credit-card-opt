module Recommendations
  class BuildExplanation
    include ActiveSupport::NumberHelper

    def self.call(card:, rule:, amount:, category:, earning_rate:, points_earned:, estimated_value_cents:)
      new(
        card: card,
        rule: rule,
        amount: amount,
        category: category,
        earning_rate: earning_rate,
        points_earned: points_earned,
        estimated_value_cents: estimated_value_cents
      ).call
    end

    def initialize(card:, rule:, amount:, category:, earning_rate:, points_earned:, estimated_value_cents:)
      @card = card
      @rule = rule
      @amount = amount
      @category = category
      @earning_rate = earning_rate
      @points_earned = points_earned
      @estimated_value_cents = estimated_value_cents
    end

    def call
      [ rate_sentence, earnings_sentence, spend_cap_sentence ].compact.join(" ")
    end

    private

    attr_reader :card, :rule, :amount, :category, :earning_rate, :points_earned, :estimated_value_cents

    def rate_sentence
      if rule
        "#{card.name} earns #{format_rate} on #{category}."
      else
        "#{card.name} has no #{category} rule, so its base rate of #{format_rate} applies."
      end
    end

    def earnings_sentence
      "Spending #{format_dollars(amount)} earns #{format_number(points_earned)} #{card.reward_currency.name} worth about #{format_cents(estimated_value_cents)}."
    end

    def spend_cap_sentence
      return unless rule&.spend_cap_cents&.positive?

      "This rate applies up to #{format_cents(rule.spend_cap_cents)} of spend."
    end

    def format_rate
      "#{format_number(earning_rate)}x"
    end

    def format_dollars(dollars)
      number_to_currency(dollars)
    end

    def format_cents(cents)
      format_dollars(BigDecimal(cents.to_s) / 100)
    end

    def format_number(value)
      decimal = BigDecimal(value.to_s)
      decimal == decimal.to_i ? decimal.to_i.to_s : decimal.to_s("F")
    end
  end
end
