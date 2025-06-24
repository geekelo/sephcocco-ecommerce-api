# app/controllers/api/v1/concerns/orders_controller_helper.rb
module Api::V1::Concerns::OrdersControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, only: [ :create, :update, :destroy, :user_orders, :user_order_create, :user_order_update, :user_order_destroy ]
    before_action :set_order, only: [ :update, :destroy, :user_order_update, :user_order_destroy ]
    before_action :set_customer, only: [ :create ]
  end

  def index
      if current_user.sephcocco_user_role.name == "admin"
        order = order_class.all
        render json: orders, each_serializer: order_serializer_class
      else
        orders = current_user.send(order_association)
        render json: orders, each_serializer: order_serializer_class
      end
  end

  def create
    unit_price = params[:unit_price] || product_class.find(order_params[:sephcocco_product_id]).price
    if current_user&.sephcocco_user_role&.name == "admin"
      order = @customer&.send(order_association).new(order_params.merge(unit_price: unit_price))
    else
      order = current_user.send(order_association).new(order_params.merge(unit_price: unit_price))
    end

    if order&.save
      if current_user.sephcocco_user_role.name == "user"
        AdminNotifications::CreateService.new(
          action_type: "order",
          action_id: order.id,
          user: current_user,
          notification_class: admin_notification_class,
          outlet: outlet,
        ).call
      end
      render json: order, status: :created
    else
      render json: order&.errors || { error: "Invalid customer" }, status: :unprocessable_entity
    end
  end

  def update
    if @order.update(order_params)
      if current_user.sephcocco_user_role.name == "admin"
        render json: @order, each_serializer: order_serializer_class
      else
        render json: @order, each_serializer: order_serializer_class
      end
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @order.destroy
      render json: { message: "Order deleted successfully" }, status: :ok
    else
      render json: { error: "Failed to delete order" }, status: :unprocessable_entity
    end
  end

  private

  def set_order
    if current_user.sephcocco_user_role.name == "admin"
      @order = order_class.find(params[:id])
    else
      @order = current_user.send(order_association).find_by(id: params[:id])
    end
  end

  def set_customer
    @customer = SephcoccoUser.find_by(id: order_params[:sephcocco_user_id])
  end
end
