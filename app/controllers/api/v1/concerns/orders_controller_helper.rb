# app/controllers/api/v1/concerns/orders_controller_helper.rb
module Api::V1::Concerns::OrdersControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, only: [ :index, :create, :show, :update, :destroy, :paid_orders, :pending_orders, :completed_orders, :delivering_orders ]
    before_action :set_order, only: [ :show, :update, :destroy, :user_order_update, :user_order_destroy ]
    before_action :set_customer, only: [ :create ]
  end

  def index
    if admin?
      orders = order_class.all
      if params[:filter]
        if params[:filter][:status].present?
          orders = orders.where(status: params[:filter][:status])
        end
        if params[:filter][:search_terms].present?
          search_term = "%#{params[:filter][:search_terms]}%"
          orders = orders.joins(:sephcocco_user, :"sephcocco_#{outlet.name.downcase}_product", :"sephcocco_#{outlet.name.downcase}_payment")
                         .where(
                           "sephcocco_users.name ILIKE ? OR sephcocco_#{outlet.name.downcase}_products.name ILIKE ? OR #{order_class.table_name}.order_number ILIKE ? OR sephcocco_#{outlet.name.downcase}_payments.transaction_id ILIKE ? OR sephcocco_#{outlet.name.downcase}_payments.id::text ILIKE ? OR sephcocco_#{outlet.name.downcase}_payments.amount::text ILIKE ?",
                           search_term, search_term, search_term, search_term, search_term, search_term
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

      orders = orders.order(created_at: :desc)
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
          orders = orders.joins(:sephcocco_user, :"sephcocco_#{outlet.name.downcase}_product", :"sephcocco_#{outlet.name.downcase}_payment")
                         .where(
                           "sephcocco_users.name ILIKE ? OR sephcocco_#{outlet.name.downcase}_products.name ILIKE ? OR #{order_class.table_name}.order_number ILIKE ? OR sephcocco_#{outlet.name.downcase}_payments.transaction_id ILIKE ? OR sephcocco_#{outlet.name.downcase}_payments.id::text ILIKE ? OR sephcocco_#{outlet.name.downcase}_payments.amount::text ILIKE ?",
                           search_term, search_term, search_term, search_term, search_term, search_term
                         )        
        end
        if params[:filter][:start_date].present? && params[:filter][:end_date].present?
          orders = orders.where(created_at: params[:filter][:start_date]..params[:filter][:end_date])
        elsif params[:filter][:start_date].present?
          orders = orders.where('created_at >= ?', params[:filter][:start_date])
        elsif params[:filter][:end_date].present?
          orders = orders.where('created_at <= ?', params[:filter][:end_date])
        elsif params[:filter][:order_number].present?
          orders = orders.where(order_number: params[:filter][:order_number])
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
    end
  end

  def show
    if @order.nil?
      return render json: { error: "Order not found" }, status: :not_found
    end
    render json: @order, each_serializer: order_serializer_class
  end

  def create
    # Validate customer is set
    if admin? && @customer.nil?
      return render json: { error: "Customer is required for admin order creation" }, status: :unprocessable_entity
    end

    # check if product is already in pending order
    outlet_name = outlet.is_a?(String) ? outlet : outlet.name.to_s
    product_id = order_params[:"sephcocco_#{outlet_name.downcase}_product_id"]
    Rails.logger.info "Outlet: #{outlet.inspect}"
    Rails.logger.info "Outlet name: #{outlet_name}"
    Rails.logger.info "Product ID: #{product_id}"
    
    if product_id.present?
      begin
        product = product_class.find(product_id)
        # Check if this product already has a pending order from this user
        Rails.logger.info "Current user: #{current_user.id}"
        Rails.logger.info "Order association: #{order_association}"
        Rails.logger.info "Product: #{product.id}"
        Rails.logger.info "Product name: #{product.name}"
        Rails.logger.info "Product price: #{product.price}"
        Rails.logger.info "Product stock: #{product.amount_in_stock}"
        Rails.logger.info "Checking for pending orders..."
        if current_user.send(order_association).exists?(
          "sephcocco_#{outlet_name.downcase}_product_id": product_id,
          status: "pending"
        )
          Rails.logger.info "Product already in pending order - returning error"
          return render json: { error: "Product is already in pending order" }, status: :unprocessable_entity
        end
        Rails.logger.info "No pending orders found - continuing..."
      rescue => e
        Rails.logger.error "Error during pending order check: #{e.message}"
        Rails.logger.error e.backtrace.first(5).join("\n")
        return render json: { error: "Error checking pending orders: #{e.message}" }, status: :unprocessable_entity
      end
    end

    Rails.logger.info "About to get unit_price"
    unit_price = params[:unit_price] || (product_id.present? ? product_class.find(product_id).price : nil)
    Rails.logger.info "Unit price: #{unit_price}"
    
    Rails.logger.info "About to create order"
    if admin?
      order = @customer.send(order_association).new(order_params.merge(unit_price: unit_price))
    else
      order = current_user.send(order_association).new(order_params.merge(unit_price: unit_price))
    end
    Rails.logger.info "Order created: #{order.inspect}"

    # Set the total price before saving
    Rails.logger.info "About to set order total"
    order.set_order_total(unit_price, order_params[:quantity])
    Rails.logger.info "Order total set"
    
    Rails.logger.info "Order valid?: #{order.valid?}"
    Rails.logger.info "Order errors: #{order.errors.full_messages}" unless order.valid?
    Rails.logger.info "About to save order"
    
    if order&.save
      if admin?
        AdminNotifications::CreateService.new(
          action_type: "order",
          action_id: order.id,
          user: current_user,
          notification_class: admin_notification_class,
          outlet: outlet,
        ).call
      end

       # like the product (only if not already liked)
       product = product_class.find(order_params[:"sephcocco_#{outlet.name.downcase}_product_id"])
     
       
       # Create like only if it doesn't already exist
       existing_like = like_class.find_by(
         like_class.user_foreign_key => current_user.id, 
         like_class.product_foreign_key => product.id
       )
       
       unless existing_like
         like_class.create(
           like_class.user_foreign_key => current_user.id, 
           like_class.product_foreign_key => product.id
         )
         product.increment!(:likes)
       end
       
      render json: order, status: :created
    else
      render json: order&.errors || { error: "Invalid customer" }, status: :unprocessable_entity
    end
  end

  def update
    old_status = @order.status
    if @order.update(order_params)
      @order.set_order_total(@order.unit_price, @order.quantity)
      @order.update_stages(order_params[:status]) if order_params[:status].present?

      # Send status update email if status changed
      if order_params[:status].present? && old_status != @order.status
        OrderMailer.with(order: @order, old_status: old_status).order_status_updated_email.deliver_now
      end

      if @order.status == "delivering"
        # create shipping for order
        shipping_class = "#{outlet.name.capitalize}::Sephcocco#{outlet.name.capitalize}Shipping".constantize
        shipping_class.create(
          "sephcocco_#{outlet.name.downcase}_order_id" => @order.id,
          status: "pending",
          tracking_number: @order.order_number
        )

        # notify customer about the order via email
        OrderMailer.with(order: @order).order_created_email.deliver_now
      end

      if @order.status == "refunded"
        # Deduct from payment
        payment = payment_class.find_by(id: @order.payment_id)
        payment.update(amount: payment.amount - @order.total_price)
        payment.save!
      end

      if admin?
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "update",
          activity_name: "Order",
          activity_description: "Order Updated: #{@order.order_number}",
          outlet: outlet
        ).call
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
      if admin?
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "delete",
          activity_name: "Order",
          activity_description: "Order Deleted: #{@order.order_number}",
          outlet: outlet
        ).call
      end
      render json: { message: "Order deleted successfully" }, status: :ok
    else
      render json: { error: "Failed to delete order" }, status: :unprocessable_entity
    end
  end

  def pending_orders
    if current_user&.sephcocco_user_role&.name == "admin"
      orders = order_class.where(status: "pending").order(created_at: :desc)
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
      orders = current_user.send(order_association).where(status: "pending").order(created_at: :desc)
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
    end
  end

  def paid_orders
    statuses = ["paid", "awaiting payment approval"]
  
    if current_user&.sephcocco_user_role&.name == "admin"
      orders = order_class.where(status: statuses).order(updated_at: :desc)
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
      orders = current_user
                 .send(order_association)
                 .where(status: statuses).order(updated_at: :desc)
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
    end
  end  

  def delivering_orders
    if current_user&.sephcocco_user_role&.name == "admin"
      orders = order_class.where(status: "delivering").order(updated_at: :desc) || []
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
      orders = current_user.send(order_association).where(status: "delivering").order(updated_at: :desc) || []
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
    end
  end

  def completed_orders
    if current_user&.sephcocco_user_role&.name == "admin"
      orders = order_class.where(status: "delivered").order(updated_at: :desc)
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
      orders = current_user.send(order_association).where(status: "delivered").order(updated_at: :desc) || []
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
    if current_user&.sephcocco_user_role&.name == "admin"
      @order = order_class.find(params[:id])
    else
      @order = current_user&.send(order_association)&.find_by(id: params[:id])
    end
  end

  def set_customer
    Rails.logger.info "set_customer - current_user: #{current_user&.id}"
    Rails.logger.info "set_customer - user_role: #{current_user&.sephcocco_user_role&.name}"
    Rails.logger.info "set_customer - admin?: #{admin?}"
    
    if admin?
      # For admin users, get customer from order params
      customer_id = order_params[:sephcocco_user_id]
      if customer_id.blank?
        Rails.logger.error "Admin order creation: sephcocco_user_id is required"
        return
      end
      @customer = SephcoccoUser.find_by(id: customer_id)
      if @customer.nil?
        Rails.logger.error "Admin order creation: Customer not found with ID #{customer_id}"
        return
      end
    else
      # For regular users, they are the customer
      @customer = current_user
    end
    
    Rails.logger.info "set_customer - @customer set to: #{@customer&.id}"
  end

  def admin?
    current_user&.sephcocco_user_role&.name == "admin"
  end

  def product_class
    raise NotImplementedError, "You must implement the product_class method"
  end

  def like_class
    raise NotImplementedError, "You must implement the like_class method"
  end

  def admin_notification_class
    raise NotImplementedError, "You must implement the admin_notification_class method"
  end
end
