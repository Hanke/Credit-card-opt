module Users
  class Serialize
    def self.call(user)
      new(user).call
    end

    def initialize(user)
      @user = user
    end

    def call
      {
        id: user.id,
        email: user.email,
        created_at: user.created_at&.iso8601
      }
    end

    private

    attr_reader :user
  end
end
