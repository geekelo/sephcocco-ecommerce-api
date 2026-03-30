# app/controllers/api/v1/sephcocco_pharmacy_orders_controller.rb
class Api::V1::Pharmacy::SephcoccoPharmacyOrdersController < ApplicationController
  include Api::V1::Concerns::OrdersControllerHelper

  private

  def order_class
    Pharmacy::SephcoccoPharmacyOrder
  end

  def order_association
    :sephcocco_pharmacy_orders
  end

  def product_class
    Pharmacy::SephcoccoPharmacyProduct
  end

  def order_serializer_class
    if current_user&.sephcocco_user_role&.name == "admin"
      Pharmacy::Admin::SephcoccoPharmacyOrderSerializer
    else
      Pharmacy::User::SephcoccoPharmacyOrderSerializer
    end
  end

  def outlet
    Pharmacy
  end

  def like_class
    Pharmacy::SephcoccoPharmacyProductLike
  end

  def admin_notification_class
    Pharmacy::SephcoccoPharmacyAdminNotification
  end

  def order_serializer
    if current_user&.sephcocco_user_role&.name == "admin"
      Pharmacy::Admin::SephcoccoPharmacyOrderSerializer
    else
      Pharmacy::User::SephcoccoPharmacyOrderSerializer
    end
  end

  def order_association_prefix
    "sephcocco_Pharmacy"
  end

  def waiters_order_params
    params.require(:sephcocco_pharmacy_order).permit(
      :address,
      :additional_notes,
      products: [
        :sephcocco_pharmacy_product_id,
        :quantity
      ]
    )
  end

  def order_params
    if current_user&.sephcocco_user_role&.name == "admin"
      params.require(:sephcocco_pharmacy_order).permit(
        :sephcocco_user_id,
        :sephcocco_pharmacy_product_id,
        :quantity,
        :unit_price,
        :total_price,
        :shipping_cost,
        :total_cost,
        :status,
        :current_stage,
        :address,
        :phone_number,
        :additional_notes,
        stages: [],
      )
    else
      params.require(:sephcocco_pharmacy_order).permit(
        :sephcocco_pharmacy_product_id,
        :quantity,
        :address,
        :phone_number,
        :additional_notes
      )
    end
  end
end
