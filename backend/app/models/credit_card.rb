class CreditCard < ApplicationRecord
  belongs_to :reward_currency
  has_many :reward_rules, dependent: :destroy
  has_many :current_reward_rules, -> { current.order(:category, :effective_from) }, class_name: "RewardRule"
  has_many :user_cards, dependent: :destroy
  has_many :users, through: :user_cards

  validates :name, presence: true
  validates :issuer, presence: true
  validates :annual_fee_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :base_earn_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :active, inclusion: { in: [ true, false ] }

  scope :active, -> { where(active: true) }
  scope :search, ->(query) {
    next all if query.blank?

    pattern = "%#{sanitize_sql_like(query.to_s.squish)}%"
    where(arel_table[:name].matches(pattern).or(arel_table[:issuer].matches(pattern)))
  }
end
