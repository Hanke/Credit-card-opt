module Recommendations
  class Calculate
    BASE_RATE_LABEL = "Base earn rate".freeze

    def self.call(amount:, category:, cards:, on: Date.current)
      new(amount: amount, category: category, cards: cards, on: on).call
    end

    def initialize(amount:, category:, cards:, on: Date.current)
      @amount = BigDecimal(amount.to_s)
      @category = category.to_s
      @cards = Array(cards)
      @on = on.to_date
    end

    def call
      return [] if cards.empty?

      preload_currencies
      rules = active_rules_by_card_id
      cards.map { |card| earnings_for(card, rules[card.id]) }.sort_by { |result| ranking_key(result) }
    end

    private

    attr_reader :amount, :category, :cards, :on

    def preload_currencies
      ActiveRecord::Associations::Preloader.new(records: cards, associations: :reward_currency).call
    end

    def active_rules_by_card_id
      RewardRule
        .where(credit_card_id: cards.map(&:id))
        .for_category(category)
        .effective_on(on)
        .group_by(&:credit_card_id)
        .transform_values { |rules| rules.max_by { |rule| [ rule.effective_from, rule.id ] } }
    end

    def earnings_for(card, rule)
      earning_rate = rule ? rule.earning_rate : card.base_earn_rate
      points_earned = (amount * earning_rate).round(2)
      estimated_value_cents = (points_earned * card.reward_currency.cents_per_point).round.to_i

      {
        credit_card_id: card.id,
        card_name: card.name,
        issuer: card.issuer,
        reward_currency: card.reward_currency.name,
        cash_back: card.reward_currency.cash_back?,
        earning_rate: earning_rate,
        points_earned: points_earned,
        estimated_value_cents: estimated_value_cents,
        rule_applied: rule ? rule_label(rule) : BASE_RATE_LABEL,
        spend_cap_cents: rule&.spend_cap_cents,
        explanation: BuildExplanation.call(
          card: card,
          rule: rule,
          rate: earning_rate,
          points: points_earned,
          value_cents: estimated_value_cents,
          amount: amount,
          category: category
        )
      }
    end

    def rule_label(rule)
      "#{rule.category.humanize} rule"
    end

    def ranking_key(result)
      [ -result[:estimated_value_cents], -result[:points_earned], result[:card_name].downcase, result[:credit_card_id] ]
    end
  end
end
