# app/controllers/api/v1/restaurant/sephcocco_restaurant_analytics_controller.rb
module Api::V1::Restaurant
  class SephcoccoRestaurantAnalyticsController < ApplicationController
    include Api::V1::Concerns::AnalyticsControllerHelper

    private

    def product_class
      Restaurant::SephcoccoRestaurantProduct
    end

    def outlet
      "restaurant"
    end

    def payment_class
      Restaurant::SephcoccoRestaurantPayment
    end

    def order_class
      Restaurant::SephcoccoRestaurantOrder
    end

    def message_class
      Restaurant::SephcoccoRestaurantMessage
    end

    def product_association_name
      :sephcocco_restaurant_product
    end
  end
end 