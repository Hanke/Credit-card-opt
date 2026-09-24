module Auth
  class AuthenticateUser
    INVALID_CREDENTIALS_ERROR = "Invalid email or password".freeze

    def self.call(email:, password:)
      new(email: email, password: password).call
    end

    def initialize(email:, password:)
      @email = email
      @password = password
    end

    def call
      return failure if email.blank? || password.blank?

      user = User.find_by(email: User.normalize_value_for(:email, email))
      return failure unless user&.authenticate(password)

      Result.success(user: user, token: IssueToken.call(user))
    end

    private

    attr_reader :email, :password

    def failure
      Result.failure(INVALID_CREDENTIALS_ERROR)
    end
  end
end
