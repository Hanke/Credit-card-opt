module Api
  module V1
    class WalletController < ApplicationController
      wrap_parameters false

      before_action :authenticate_user!

      def show
        user_cards = Wallet::ListCards.call(user: current_user)

        render json: { cards: WalletCardSerializer.collection(user_cards) }, status: :ok
      end

      def create
        result = Wallet::AddCard.call(user: current_user, credit_card_id: wallet_params[:credit_card_id])

        if result.success?
          render json: { card: WalletCardSerializer.call(result.user_card) }, status: :created
        else
          render_unprocessable(result.errors)
        end
      end

      def destroy
        Wallet::RemoveCard.call(user: current_user, credit_card_id: params[:credit_card_id])

        head :no_content
      end

      private

      def wallet_params
        params.permit(:credit_card_id)
      end
    end
  end
end
