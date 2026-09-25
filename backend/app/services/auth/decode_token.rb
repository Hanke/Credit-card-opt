module Auth
  class DecodeToken
    def self.call(token)
      new(token).call
    end

    def initialize(token)
      @token = token
    end

    def call
      return nil if token.blank?

      user_id = decoded_payload&.fetch("sub", nil)
      return nil if user_id.blank?

      User.find_by(id: user_id)
    end

    private

    attr_reader :token

    def decoded_payload
      payload, _header = JWT.decode(token, secret, true, algorithm: IssueToken::ALGORITHM)
      payload
    rescue JWT::DecodeError
      nil
    end

    def secret
      Rails.application.secret_key_base
    end
  end
end
