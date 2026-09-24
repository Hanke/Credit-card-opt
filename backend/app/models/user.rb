class User < ApplicationRecord
  EMAIL_FORMAT = URI::MailTo::EMAIL_REGEXP
  PASSWORD_MIN_LENGTH = 8

  has_secure_password

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true,
                    format: { with: EMAIL_FORMAT },
                    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: PASSWORD_MIN_LENGTH }, allow_nil: true
end
