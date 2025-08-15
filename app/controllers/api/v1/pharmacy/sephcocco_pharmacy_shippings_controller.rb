# app/controllers/api/v1/pharmacy/sephcocco_pharmacy_shippings_controller.rb
class Api::V1::Pharmacy::SephcoccoPharmacyShippingsController < ApplicationController
  include Api::V1::Concerns::ShippingControllerHelper

  private

  def shipping_class
    Pharmacy::SephcoccoPharmacyShipping
  end

  def shipping_association
    :sephcocco_pharmacy_shippings
  end

  def shipping_serializer_class
    if current_user&.sephcocco_user_role&.name == "admin"
      Pharmacy::Admin::SephcoccoPharmacyShippingSerializer
    else
      Pharmacy::User::SephcoccoPharmacyShippingSerializer
    end
  end

  def admin_notification_class
    Pharmacy::SephcoccoPharmacyAdminNotification
  end

  def outlet
    "pharmacy"
  end

  def shipping_params
    params.require(:shipping).permit(
      :tracking_number,
      :status,
      :rider,
      :datetime_delivered,
      :dispatching,
      :sephcocco_pharmacy_order_id
    )
  end
end 