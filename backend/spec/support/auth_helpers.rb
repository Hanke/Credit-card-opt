module AuthHelpers
  def auth_headers(user, **token_options)
    { "Authorization" => "Bearer #{Auth::IssueToken.call(user, **token_options)}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
  config.include ActiveSupport::Testing::TimeHelpers
end
