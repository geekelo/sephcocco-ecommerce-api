class Api::V1::Restaurant::SephcoccoRestaurantPayment < ApplicationRecord
  include Api::V1::PaymentModelHelper

  belongs_to :sephcocco_user, class_name: "SephcoccoUser", foreign_key: :sephcocco_user_id, optional: true

  def associated_order_class
    Api::V1::Restaurant::SephcoccoRestaurantOrder
  end
end
