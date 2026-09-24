class RewardRule < ApplicationRecord
  belongs_to :credit_card

  validates :category, presence: true, inclusion: { in: PurchaseCategories::ALL }
  validates :earning_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :spend_cap_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :effective_from, presence: true
  validates :effective_to, comparison: { greater_than_or_equal_to: :effective_from }, allow_nil: true

  scope :for_category, ->(category) { where(category: category) }
  scope :effective_on, ->(date) { where(effective_from: ..date, effective_to: [ nil, date.. ]) }
  scope :current, -> { effective_on(Date.current) }
end
