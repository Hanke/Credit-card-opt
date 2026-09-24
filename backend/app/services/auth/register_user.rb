module Auth
  class RegisterUser
    DUPLICATE_EMAIL_ERROR = "Email has already been taken".freeze

    def self.call(email:, password:)
      new(email: email, password: password).call
    end

    def initialize(email:, password:)
      @email = email
      @password = password
    end

    def call
      user = User.new(email: email, password: password)

      if user.save
        Result.success(user: user, token: IssueToken.call(user))
      else
        Result.failure(user.errors.full_messages)
      end
    rescue ActiveRecord::RecordNotUnique
      Result.failure(DUPLICATE_EMAIL_ERROR)
    end

    private

    attr_reader :email, :password
  end
end
