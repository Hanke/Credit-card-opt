module Auth
  class IssueToken
    ALGORITHM = "HS256"
    TTL = 7.days

    def self.call(user, now: Time.current)
      new(user, now: now).call
    end

    def initialize(user, now: Time.current)
      @user = user
      @now = now
    end

    def call
      JWT.encode(payload, secret, ALGORITHM)
    end

    private

    attr_reader :user, :now

    def payload
      {
        sub: user.id.to_s,
        iat: now.to_i,
        exp: (now + TTL).to_i
      }
    end

    def secret
      Rails.application.secret_key_base
    end
  end
end
