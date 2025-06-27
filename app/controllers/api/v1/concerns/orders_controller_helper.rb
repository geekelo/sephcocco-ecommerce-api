# app/controllers/api/v1/concerns/orders_controller_helper.rb
module Api::V1::Concerns::OrdersControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, only: [ :index, :create, :update, :destroy, :paid_orders, :pending_orders, :completed_orders ]
    before_action :set_order, only: [ :update, :destroy, :user_order_update, :user_order_destroy ]
    before_action :set_customer, only: [ :create ]
  end

  def index
    if current_user&.sephcocco_user_role&.name == "admin"
      orders = order_class.all
      if params[:filter]
        if params[:filter][:status].present?
          orders = orders.where(status: params[:filter][:status])
        end
        if params[:filter][:search_terms].present?
          search_term = "%#{params[:filter][:search_terms]}%"
          orders = orders.joins(:sephcocco_user, :sephcocco_pharmacy_product)
                         .where(
                           "sephcocco_users.name ILIKE ? OR sephcocco_#{outlet.downcase}_products.name ILIKE ?",
                           search_term, search_term
                         )        
        end
        if params[:filter][:start_date].present? && params[:filter][:end_date].present?
          orders = orders.where(created_at: params[:filter][:start_date]..params[:filter][:end_date])
        elsif params[:filter][:start_date].present?
          orders = orders.where('created_at >= ?', params[:filter][:start_date])
        elsif params[:filter][:end_date].present?
          orders = orders.where('created_at <= ?', params[:filter][:end_date])
        end
      end
      orders = orders.page(params[:page]).per(params[:per_page] || 20) || []
      render json: {
        orders: ActiveModelSerializers::SerializableResource.new(
        orders, 
        each_serializer: order_serializer_class
        ).as_json,
        meta: {
          total_count: orders.total_count,
          total_pages: orders.total_pages,
          current_page: orders.current_page
        }
      }
    else
      orders = current_user.send(order_association)
      if params[:filter]
        if params[:filter][:status].present?
          orders = orders.where(status: params[:filter][:status])
        end
        if params[:filter][:search_terms].present?
          search_term = "%#{params[:filter][:search_terms]}%"
          orders = orders.joins(:sephcocco_user, :sephcocco_pharmacy_product)
                         .where(
                           "sephcocco_users.name ILIKE ? OR sephcocco_#{outlet.downcase}_products.name ILIKE ?",
                           search_term, search_term
                         )        
        end
        if params[:filter][:start_date].present? && params[:filter][:end_date].present?
          orders = orders.where(created_at: params[:filter][:start_date]..params[:filter][:end_date])
        elsif params[:filter][:start_date].present?
          orders = orders.where('created_at >= ?', params[:filter][:start_date])
        elsif params[:filter][:end_date].present?
          orders = orders.where('created_at <= ?', params[:filter][:end_date])
        end
      end
      render json: orders, each_serializer: order_serializer_class
    end
  end

  def create
    unit_price = params[:unit_price] || product_class.find(order_params[:sephcocco_pharmacy_product_id]).price || product_class.find(order_params[:sephcocco_restaurant_product_id]).price || product_class.find(order_params[:sephcocco_lounge_product_id]).price
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

  def show
    if current_user.sephcocco_user_role.name == "admin"
      render json: @order, each_serializer: order_serializer_class
    else
      render json: @order, each_serializer: order_serializer_class
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

  def pending_orders
    if current_user&.sephcocco_user_role&.name == "admin"
      order = order_class.where(status: "pending")
      render json: orders, each_serializer: order_serializer_class
    else
      orders = current_user.send(order_association).where(status: "pending")
      render json: orders, each_serializer: order_serializer_class
    end
  end

  def paid_orders
    if current_user&.sephcocco_user_role&.name == "admin"
      order = order_class.where(status: "paid")
      render json: orders, each_serializer: order_serializer_class
    else
      orders = current_user.send(order_association).where(status: "paid") || []
      render json: orders, each_serializer: order_serializer_class
    end
  end

  def completed_orders
    if current_user&.sephcocco_user_role&.name == "admin"
      order = order_class.where(status: "completed")
      render json: orders, each_serializer: order_serializer_class
    else
      orders = current_user.send(order_association).where(status: "completed") || []
      orders = orders.page(params[:page]).per(params[:per_page] || 20) || []
      render json: {
        orders: ActiveModelSerializers::SerializableResource.new(
          orders,
          each_serializer: order_serializer_class,
          adapter: :attributes,
          scope: current_user
        ).as_json,
        meta: {
          total_count: orders.total_count,
          total_pages: orders.total_pages,
          current_page: orders.current_page
        }
      }
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
