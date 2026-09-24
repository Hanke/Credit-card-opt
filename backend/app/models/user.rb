class User < ApplicationRecord
  EMAIL_FORMAT = URI::MailTo::EMAIL_REGEXP
  PASSWORD_MIN_LENGTH = 8

  has_secure_password

  has_many :user_cards, dependent: :destroy
  has_many :credit_cards, through: :user_cards

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true,
                    format: { with: EMAIL_FORMAT },
                    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: PASSWORD_MIN_LENGTH }, allow_nil: true
end
