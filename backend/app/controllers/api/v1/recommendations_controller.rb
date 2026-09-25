module Api
  module V1
    class RecommendationsController < ApplicationController
      wrap_parameters false

      before_action :authenticate_user!

      def create
        result = Recommendations::ForPurchase.call(
          user: current_user,
          amount: recommendation_params[:amount],
          category: recommendation_params[:category],
          credit_card_ids: recommendation_params[:credit_card_ids]
        )

        if result.success?
          render json: PurchaseRecommendationSerializer.call(result), status: :ok
        else
          render_unprocessable(result.errors)
        end
      end

      private

      def recommendation_params
        params.permit(:amount, :category, credit_card_ids: [])
      end
    end
  end
end
