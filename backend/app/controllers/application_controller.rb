class ApplicationController < ActionController::API
  include ErrorRendering
  include Authenticable
end
