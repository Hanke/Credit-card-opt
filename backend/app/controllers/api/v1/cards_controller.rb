module Api
  module V1
    class CardsController < ApplicationController
      before_action :authenticate_user!

      def index
        cards = Cards::Search.call(query: search_params[:q])

        render json: { cards: CreditCardSerializer.collection(cards) }, status: :ok
      end

      def show
        card = Cards::Find.call(id: params[:id])

        render json: { card: CreditCardDetailSerializer.call(card) }, status: :ok
      end

      private

      def search_params
        params.permit(:q)
      end
    end
  end
end
