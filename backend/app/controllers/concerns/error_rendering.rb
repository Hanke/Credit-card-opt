module ErrorRendering
  extend ActiveSupport::Concern

  private

  def render_unauthorized(message = "You must be logged in")
    response.set_header("WWW-Authenticate", 'Bearer realm="api"')
    render json: { errors: [ message ] }, status: :unauthorized
  end

  def render_unprocessable(errors)
    render json: { errors: Array(errors) }, status: :unprocessable_content
  end
end
