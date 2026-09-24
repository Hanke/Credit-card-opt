module Seeds
  class UpsertCreditCard
    RULE_ATTRIBUTES = %i[earning_rate spend_cap_cents effective_to notes].freeze

    def self.call(**attributes)
      new(**attributes).call
    end

    def initialize(name:, issuer:, currency:, base_earn_rate:, network: nil, annual_fee_cents: 0,
                   active: true, notes: nil, effective_from: nil, rules: [])
      @name = name
      @issuer = issuer
      @currency = currency
      @base_earn_rate = base_earn_rate
      @network = network
      @annual_fee_cents = annual_fee_cents
      @active = active
      @notes = notes
      @effective_from = effective_from
      @rules = rules
    end

    def call
      CreditCard.transaction do
        card = CreditCard.find_or_initialize_by(name: name)
        card.assign_attributes(
          issuer: issuer,
          network: network,
          annual_fee_cents: annual_fee_cents,
          base_earn_rate: base_earn_rate,
          active: active,
          notes: notes,
          reward_currency: reward_currency
        )
        card.save!
        rules.each { |rule| upsert_rule(card, rule) }
        card
      end
    end

    private

    attr_reader :name, :issuer, :currency, :base_earn_rate, :network, :annual_fee_cents,
                :active, :notes, :effective_from, :rules

    def reward_currency
      return currency if currency.is_a?(RewardCurrency)

      RewardCurrency.find_by!(name: currency)
    end

    def upsert_rule(card, attributes)
      attributes = attributes.to_h.symbolize_keys
      rule = card.reward_rules.find_or_initialize_by(
        category: attributes.fetch(:category).to_s,
        effective_from: attributes.fetch(:effective_from, effective_from)
      )
      rule.assign_attributes(attributes.slice(*RULE_ATTRIBUTES))
      rule.save!
      rule
    end
  end
end
