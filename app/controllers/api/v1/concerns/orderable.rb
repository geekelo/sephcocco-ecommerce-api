# app/controllers/api/v1/concerns/orderable.rb
module Api::V1::Concerns::Orderable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, only: [:create, :update, :destroy, :user_orders, :user_order_create, :user_order_update, :user_order_destroy]
    before_action :set_order, only: [:update, :destroy, :user_order_update, :user_order_destroy]
    before_action :set_customer, only: [:create]
  end

  def index
    orders = 
      if current_user.sephcocco_user_role.name == 'admin'
        order_class.all
      else
        current_user.send(order_association)
      end
    render json: orders
  end

  def create
    order = 
    if current_user.sephcocco_user_role.name == 'admin'
      @customer&.send(order_association).new(order_params)
    else
      order = current_user.send(order_association).new(order_params)
    end

    if order&.save
      render json: order, status: :created
    else
      render json: order&.errors || { error: 'Invalid customer' }, status: :unprocessable_entity
    end
  end

  def update
    if @order.update(order_params)
      render json: @order
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @order.destroy
      render json: { message: 'Order deleted successfully' }, status: :ok
    else
      render json: { error: 'Failed to delete order' }, status: :unprocessable_entity
    end
  end

  private

  def set_order
    if current_user.sephcocco_user_role.name == 'admin'
      @order = order_class.find(params[:id])
    else
      @order = current_user.send(order_association).find_by(id: params[:id])
    end
  end

  def set_customer
    @customer = SephcoccoUser.find_by(id: order_params[:sephcocco_user_id])
  end
end
