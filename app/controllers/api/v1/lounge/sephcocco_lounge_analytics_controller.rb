# app/controllers/api/v1/lounge/sephcocco_lounge_analytics_controller.rb
module Api::V1::Lounge
  class SephcoccoLoungeAnalyticsController < ApplicationController
    include Api::V1::Concerns::AnalyticsControllerHelper

    private

    def product_class
      Lounge::SephcoccoLoungeProduct
    end

    def outlet
      "lounge"
    end

    def payment_class
      Lounge::SephcoccoLoungePayment
    end

    def order_class
      Lounge::SephcoccoLoungeOrder
    end

    def message_class
      Lounge::SephcoccoLoungeMessage
    end

    def product_association_name
      :sephcocco_lounge_product
    end
  end
end 