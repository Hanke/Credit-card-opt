module Api
  module V1
    class AuthController < ApplicationController
      wrap_parameters false

      before_action :authenticate_user!, only: :me

      def signup
        result = Auth::RegisterUser.call(**credential_params)

        if result.success?
          render json: session_payload(result), status: :created
        else
          render_unprocessable(result.errors)
        end
      end

      def login
        result = Auth::AuthenticateUser.call(**credential_params)

        if result.success?
          render json: session_payload(result), status: :ok
        else
          render_unauthorized(result.errors.first)
        end
      end

      def logout
        head :no_content
      end

      def me
        render json: { user: UserSerializer.call(current_user) }, status: :ok
      end

      private

      def credential_params
        permitted = params.permit(:email, :password)
        { email: permitted[:email].to_s, password: permitted[:password].to_s }
      end

      def session_payload(result)
        { token: result.token, user: UserSerializer.call(result.user) }
      end
    end
  end
end
