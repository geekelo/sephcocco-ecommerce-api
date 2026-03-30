# app/controllers/api/v1/sephcocco_lounge_orders_controller.rb
class Api::V1::Lounge::SephcoccoLoungeOrdersController < ApplicationController
  include Api::V1::Concerns::OrdersControllerHelper

  private

  def order_class
    Lounge::SephcoccoLoungeOrder
  end

  def order_association
    :sephcocco_lounge_orders
  end

  def product_class
    Lounge::SephcoccoLoungeProduct
  end

  def like_class
    Lounge::SephcoccoLoungeProductLike
  end

  def order_serializer_class
    if current_user&.sephcocco_user_role&.name == "admin"
      Lounge::Admin::SephcoccoLoungeOrderSerializer
    else
      Lounge::User::SephcoccoLoungeOrderSerializer
    end
  end

  def outlet
    Lounge
  end

  def admin_notification_class
    Lounge::SephcoccoLoungeAdminNotification
  end

  def order_serializer
    if current_user&.sephcocco_user_role&.name == "admin"
      Lounge::Admin::SephcoccoLoungeOrderSerializer
    else
      Lounge::User::SephcoccoLoungeOrderSerializer
    end
  end

  def order_association_prefix
    "sephcocco_Lounge"
  end

  def waiters_order_params
    params.require(:sephcocco_lounge_order).permit(
      :address,
      :additional_notes,
      products: [
        :sephcocco_lounge_product_id,
        :quantity
      ]
    )
  end

  def order_params
    if current_user&.sephcocco_user_role&.name == "admin"
      params.require(:sephcocco_lounge_order).permit(
        :sephcocco_user_id,
        :sephcocco_lounge_product_id,
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
        stages: []
      )
    else
      params.require(:sephcocco_lounge_order).permit(
        :sephcocco_lounge_product_id,
        :quantity,
        :address,
        :phone_number,
        :additional_notes
      )
    end
  end
end
