class UserSerializer < ApplicationSerializer
  def call
    {
      id: record.id,
      email: record.email,
      created_at: record.created_at&.iso8601
    }
  end
end
