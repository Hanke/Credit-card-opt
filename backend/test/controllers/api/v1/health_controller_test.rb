require "test_helper"

module Api
  module V1
    class HealthControllerTest < ActionDispatch::IntegrationTest
      test "returns ok" do
        get api_v1_health_url
        assert_response :success
        assert_equal "ok", response.parsed_body["status"]
      end
    end
  end
end
