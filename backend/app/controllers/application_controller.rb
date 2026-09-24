class ApplicationController < ActionController::API
  include ErrorRendering
  include Authenticable

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
end
