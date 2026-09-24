module Auth
  Result = Struct.new(:user, :token, :errors, keyword_init: true) do
    def self.success(user:, token:)
      new(user: user, token: token, errors: [])
    end

    def self.failure(errors)
      new(user: nil, token: nil, errors: Array(errors))
    end

    def success? = errors.empty?
  end
end
