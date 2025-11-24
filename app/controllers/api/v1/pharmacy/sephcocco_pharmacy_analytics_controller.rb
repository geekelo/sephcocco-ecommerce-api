# app/controllers/api/v1/pharmacy/sephcocco_pharmacy_analytics_controller.rb
module Api::V1::Pharmacy
  class SephcoccoPharmacyAnalyticsController < ApplicationController
    include Api::V1::Concerns::AnalyticsControllerHelper

    private

    def product_class
      Pharmacy::SephcoccoPharmacyProduct
    end

    def outlet
      "pharmacy"
    end

    def payment_class
      Pharmacy::SephcoccoPharmacyPayment
    end

    def order_class
      Pharmacy::SephcoccoPharmacyOrder
    end

    def message_class
      Pharmacy::SephcoccoPharmacyMessage
    end

    def product_association_name
      :sephcocco_pharmacy_product
    end
  end
end 