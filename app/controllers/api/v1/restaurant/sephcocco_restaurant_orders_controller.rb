# app/controllers/api/v1/sephcocco_restaurant_orders_controller.rb
class Api::V1::Restaurant::SephcoccoRestaurantOrdersController < ApplicationController
  include Api::V1::Concerns::OrdersControllerHelper

  private

  def order_class
    SephcoccoRestaurantOrder
  end

  def order_association
    :sephcocco_restaurant_orders
  end

  def order_params
    if current_user.sephcocco_user_role.name == "admin"
      params.require(:sephcocco_restaurant_order).permit(
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
      params.require(:sephcocco_restaurant_order).permit(:quantity)
    end
  end
end
