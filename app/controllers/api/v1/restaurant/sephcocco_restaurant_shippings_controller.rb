# app/controllers/api/v1/restaurant/sephcocco_restaurant_shippings_controller.rb
class Api::V1::Restaurant::SephcoccoRestaurantShippingsController < ApplicationController
  include Api::V1::Concerns::ShippingControllerHelper

  private

  def shipping_class
    Restaurant::SephcoccoRestaurantShipping
  end

  def order_association
    :sephcocco_restaurant_order
  end

  def shipping_association
    :sephcocco_restaurant_shippings
  end

  def shipping_serializer_class
    if current_user&.sephcocco_user_role&.name == "admin"
      Restaurant::Admin::SephcoccoRestaurantShippingSerializer
    else
      Restaurant::User::SephcoccoRestaurantShippingSerializer
    end
  end

  def admin_notification_class
    Restaurant::SephcoccoRestaurantAdminNotification
  end

  def outlet
    "restaurant"
  end

  def shipping_params
    params.require(:shipping).permit(
      :tracking_number,
      :status,
      :rider,
      :datetime_delivered,
      :dispatching,
      :sephcocco_restaurant_order_id
    )
  end
end 