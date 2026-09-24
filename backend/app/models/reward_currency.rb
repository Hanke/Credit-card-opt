class RewardCurrency < ApplicationRecord
  has_many :credit_cards, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :cents_per_point, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
