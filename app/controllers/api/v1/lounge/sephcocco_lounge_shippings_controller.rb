# app/controllers/api/v1/lounge/sephcocco_lounge_shippings_controller.rb
class Api::V1::Lounge::SephcoccoLoungeShippingsController < ApplicationController
  include Api::V1::Concerns::ShippingControllerHelper

  private

  def shipping_class
    Lounge::SephcoccoLoungeShipping
  end

  def order_association
    :sephcocco_lounge_order
  end

  def shipping_association
    :sephcocco_lounge_shippings
  end

  def shipping_serializer_class
    if current_user&.sephcocco_user_role&.name == "admin"
      Lounge::Admin::SephcoccoLoungeShippingSerializer
    else
      Lounge::User::SephcoccoLoungeShippingSerializer
    end
  end

  def admin_notification_class
    Lounge::SephcoccoLoungeAdminNotification
  end

  def outlet
    "lounge"
  end

  def shipping_params
    params.require(:shipping).permit(
      :tracking_number,
      :status,
      :rider,
      :datetime_delivered,
      :dispatching,
      :sephcocco_lounge_order_id
    )
  end
end 