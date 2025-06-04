# app/controllers/api/v1/sephcocco_lounge_orders_controller.rb
class Api::V1::Lounge::SephcoccoLoungeOrdersController < ApplicationController
  include Api::V1::Concerns::OrdersControllerHelper

  private

  def order_class
    SephcoccoLoungeOrder
  end

  def order_association
    :sephcocco_lounge_orders
  end

  def outlet
    Lounge
  end

  def order_serializer
    if current_user.sephcocco_user_role.name == "admin"
      Lounge::Admin::SephcoccoLoungeOrderSerializer
    else
      Lounge::User::SephcoccoLoungeOrderSerializer
    end
  end

  def order_association_prefix
    "sephcocco_lounge"
  end

  def order_params
    if current_user.sephcocco_user_role.name == "admin"
      params.require(:sephcocco_lounge_order).permit(
        :sephcocco_user_id,
        :quantity,
        :unit_price,
        :total_price,
        :shipping_cost,
        :total_cost,
        :status,
        :order_number,
        stages: []
      )
    else
      params.require(:sephcocco_lounge_order).permit(:quantity)
    end
  end
end
