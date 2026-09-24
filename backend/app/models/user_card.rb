class UserCard < ApplicationRecord
  belongs_to :user
  belongs_to :credit_card

  attribute :added_at, default: -> { Time.current }

  validates :added_at, presence: true
  validates :credit_card_id, uniqueness: { scope: :user_id }
end
