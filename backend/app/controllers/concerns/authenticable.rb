module Authenticable
  extend ActiveSupport::Concern

  include ErrorRendering

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = Auth::DecodeToken.call(bearer_token)
  end

  def user_signed_in?
    current_user.present?
  end

  def authenticate_user!
    render_unauthorized unless user_signed_in?
  end

  def bearer_token
    scheme, token = request.authorization.to_s.strip.split(/\s+/, 2)
    token if scheme&.casecmp?("Bearer")
  end
end
