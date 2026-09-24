module Recommendations
  class BuildExplanation
    include ActiveSupport::NumberHelper

    def self.call(card:, rule:, rate:, points:, value_cents:, amount:, category:)
      new(card: card, rule: rule, rate: rate, points: points, value_cents: value_cents, amount: amount, category: category).call
    end

    def initialize(card:, rule:, rate:, points:, value_cents:, amount:, category:)
      @card = card
      @rule = rule
      @rate = BigDecimal(rate.to_s)
      @points = BigDecimal(points.to_s)
      @value_cents = Integer(value_cents)
      @amount = BigDecimal(amount.to_s)
      @category_label = category.to_s.downcase
      @cash_back = card.reward_currency.cash_back?
    end

    def call
      [ rate_sentence, math_sentence, spend_cap_note ].compact.join(" ")
    end

    private

    attr_reader :card, :rule, :rate, :points, :value_cents, :amount, :category_label, :cash_back

    def rate_sentence
      if rule
        "#{card.name} earns #{earn_label} on #{category_label}."
      else
        "#{card.name} has no #{category_label} bonus, so the base rate of #{rate_label} applies."
      end
    end

    def earn_label
      cash_back ? "#{rate_label} cash back" : "#{rate_label} #{card.reward_currency.name}"
    end

    def math_sentence
      if cash_back
        "#{format_number(amount)} × #{rate_label} = #{format_money(value_cents)}"
      else
        "#{format_number(amount)} × #{format_number(rate)} = #{format_number(points)} pts ≈ #{format_money(value_cents)}"
      end
    end

    def spend_cap_note
      return unless rule&.spend_cap_cents&.positive?

      "(bonus rate applies up to #{format_money(rule.spend_cap_cents, whole_dollars_without_cents: true)}/year)"
    end

    def rate_label
      cash_back ? "#{format_number(rate)}%" : "#{format_number(rate)}x"
    end

    def format_money(cents, whole_dollars_without_cents: false)
      dollars = BigDecimal(cents.to_s) / 100
      precision = whole_dollars_without_cents && dollars == dollars.to_i ? 0 : 2
      number_to_currency(dollars, precision: precision)
    end

    def format_number(value)
      decimal = BigDecimal(value.to_s)
      number_to_delimited(decimal == decimal.to_i ? decimal.to_i : decimal.to_s("F"))
    end
  end
end
