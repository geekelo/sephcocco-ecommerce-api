# app/controllers/api/v1/concerns/orders_controller_helper.rb
module Api::V1::Concerns::OrdersControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, only: [ :index, :create, :show, :update, :destroy, :paid_orders, :pending_orders, :completed_orders, :delivering_orders, :admin_order_creation ]
    before_action :set_order, only: [ :show, :update, :destroy, :user_order_update, :user_order_destroy ]
    before_action :set_customer, only: [ :create, :admin_order_creation ]
  end

  def index
    # if admin and not waiters
    is_waiter = current_user&.sephcocco_user_subroles&.exists?(name: "waiters")
    if admin? && !is_waiter
      orders = order_class.all
      if params[:filter]
        # String "true" / "1" from query params must match (== true only matches JSON boolean true)
        if ActiveModel::Type::Boolean.new.cast(params[:filter][:waiters])
          # orders whose customer (sephcocco_user) has the "waiters" subrole
          orders = orders
                   .joins(sephcocco_user: :sephcocco_user_subroles)
                   .where(sephcocco_user_subroles: { name: "waiters" })
                   .distinct
        end

        if params[:filter][:waiter_id].present?
          orders = orders.joins(sephcocco_user: :sephcocco_user_subroles)
                         .where(sephcocco_user_subroles: { name: "waiters", id: params[:filter][:waiter_id] })
        end
        
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

        # Apply department_id filter
        if params[:filter][:department_id].present?
          dept = params[:filter][:department_id].to_s.strip
          unless dept.blank? || dept.casecmp("all department").zero? || dept.casecmp("all").zero?
            orders = orders.joins(:"sephcocco_#{outlet.name.downcase}_department")
            orders = orders.where(:"sephcocco_#{outlet.name.downcase}_department.id" => dept)
          end
        end
        
        if params[:filter][:start_date].present? && params[:filter][:end_date].present?
          orders = orders.where("#{order_class.table_name}.created_at" => params[:filter][:start_date]..params[:filter][:end_date])
        elsif params[:filter][:start_date].present?
          orders = orders.where("#{order_class.table_name}.created_at >= ?", params[:filter][:start_date])
        elsif params[:filter][:end_date].present?
          orders = orders.where("#{order_class.table_name}.created_at <= ?", params[:filter][:end_date])
        end
      end

      per_page = (params[:per_page] || 20).to_i
      page = (params[:page] || 1).to_i

      group_page = orders
                   .unscope(:order)
                   .distinct(false)
                   .group(:order_number)
                   .reorder(Arel.sql("MAX(#{order_class.table_name}.created_at) DESC"))
                   .select(:order_number)
                   .page(page)
                   .per(per_page)

      order_numbers = group_page.pluck(:order_number)
      orders = orders.where(order_number: order_numbers).order(created_at: :desc).to_a

      render json: {
        orders: ActiveModelSerializers::SerializableResource.new(
          GroupedOrdersCollection.new(orders: orders),
          serializer: grouped_orders_serializer_class,
          group_order_numbers: order_numbers
        ).as_json,
        meta: {
          total_count: group_page.total_count,
          total_pages: group_page.total_pages,
          current_page: group_page.current_page,
          per_page: group_page.limit_value
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
          orders = orders.where("#{order_class.table_name}.created_at" => params[:filter][:start_date]..params[:filter][:end_date])
        elsif params[:filter][:start_date].present?
          orders = orders.where("#{order_class.table_name}.created_at >= ?", params[:filter][:start_date])
        elsif params[:filter][:end_date].present?
          orders = orders.where("#{order_class.table_name}.created_at <= ?", params[:filter][:end_date])
        elsif params[:filter][:order_number].present?
          orders = orders.where(order_number: params[:filter][:order_number])
        end
      end
      per_page = (params[:per_page] || 20).to_i
      page = (params[:page] || 1).to_i

      group_page = orders
                   .unscope(:order)
                   .distinct(false)
                   .group(:order_number)
                   .reorder(Arel.sql("MAX(#{order_class.table_name}.created_at) DESC"))
                   .select(:order_number)
                   .page(page)
                   .per(per_page)

      order_numbers = group_page.pluck(:order_number)
      orders = orders.where(order_number: order_numbers).order(created_at: :desc).to_a
      render json: {
        orders: ActiveModelSerializers::SerializableResource.new(
          GroupedOrdersCollection.new(orders: orders),
          serializer: grouped_orders_serializer_class,
          group_order_numbers: order_numbers
        ).as_json,
        meta: {
          total_count: group_page.total_count,
          total_pages: group_page.total_pages,
          current_page: group_page.current_page,
          per_page: group_page.limit_value
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

     # Check for existing pending order for this product
    existing_order = order_class.find_by(
      sephcocco_user_id: current_user.id,
      "sephcocco_#{outlet.name.downcase}_product_id": order_params[:"sephcocco_#{outlet.name.downcase}_product_id"],
      status: "pending"
    )
       
    if existing_order.present?
      return render json: { error: "You already have a pending order for this product", message: "You already have a pending order for this product" }, status: :unprocessable_entity
    end

    order_number = DateTime.now.strftime("%Y%m%d%H%M%S")

    product = product_class.find(order_params[:"sephcocco_#{outlet.name.downcase}_product_id"])

    # check if product is out of stock
    amount_in_stock = product.amount_in_stock
    if amount_in_stock == 0 || amount_in_stock < order_params[:quantity]
      return render json: { error: "Product is out of stock, available stock is #{amount_in_stock}" }, status: :unprocessable_entity
    end

    unit_price = product.price
    if admin?
      order = @customer.send(order_association).new(order_params.merge(unit_price: unit_price))
    else
      order = current_user.send(order_association).new(order_params.merge(unit_price: unit_price))
    end

    # Set the total price before saving
    order.set_order_total(unit_price, order_params[:quantity], order_number)
    
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
    if admin? && params[:order_ids].present?
      return admin_bulk_update_orders
    end

    update_single_order(@order)
  end

  private

  def admin_bulk_update_orders
    order_ids = Array(params[:order_ids]).map(&:to_s).uniq
    orders = order_class.where(id: order_ids)

    updated = []
    failed = []

    orders.find_each do |order|
      ok, payload = update_single_order(order, render: false)
      if ok
        updated << payload
      else
        failed << { id: order.id, errors: payload }
      end
    end

    if failed.any?
      render json: { updated: updated, failed: failed }, status: :unprocessable_entity
    else
      render json: { updated: updated }, status: :ok
    end
  end

  def update_single_order(order, render: true)
    old_status = order.status

    if order_params[:quantity].present?
      product_id = order.send(:"sephcocco_#{outlet.name.downcase}_product_id")
      amount_in_stock = product_class.find(product_id).amount_in_stock
      if order_params[:quantity] > amount_in_stock || amount_in_stock == 0
        payload = { error: "Product is out of stock, available stock is #{amount_in_stock}", amount_in_stock: amount_in_stock }
        return render ? render(json: payload, status: :unprocessable_entity) : [false, payload]
      end
    end

    if order.update(order_params)
      order.set_order_total(order.unit_price, order.quantity)
      order.update_stages(order_params[:status]) if order_params[:status].present?

      if order_params[:status].present? && old_status != order.status
        OrderMailer.with(order: order, old_status: old_status).order_status_updated_email.deliver_now

        if order.status == "delivering"
          shipping_class = "#{outlet.name.capitalize}::Sephcocco#{outlet.name.capitalize}Shipping".constantize
          shipping_class.create(
            "sephcocco_#{outlet.name.downcase}_order_id" => order.id,
            status: "pending",
            tracking_number: order.order_number
          )
          OrderMailer.with(order: order).order_created_email.deliver_now
        end

        if order.status == "refunded" || order.status == "cancelled" || order.status == "discarded"
          payment_assoc = :"sephcocco_#{outlet.name.downcase}_payment"
          payment = order.respond_to?(payment_assoc) ? order.public_send(payment_assoc) : nil
          if payment
            payment.update(amount: payment.amount - order.total_price)
            payment.save!
          end

          product = product_class.find(order.send(:"sephcocco_#{outlet.name.downcase}_product_id"))
          product.update!(amount_in_stock: product.amount_in_stock + order.quantity)
          product.save!

          if order.status == "discarded"
            order.destroy
            if admin?
              AdminActivities::CreateService.new(
                user: current_user,
                activity_type: "delete",
                activity_name: "Order",
                activity_description: "Order Deleted: #{@order.order_number}",
                outlet: outlet
              ).call
            end
          end

          if order.status == "refunded"
            OrderMailer.with(order: order).order_refunded_email.deliver_now
          elsif order.status == "cancelled"
            OrderMailer.with(order: order).order_cancelled_email.deliver_now
          elsif order.status == "discarded"
            OrderMailer.with(order: order).order_discarded_email.deliver_now
          end
        end
      end

      if admin?
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "update",
          activity_name: "Order",
          activity_description: "Order Status Updated: #{order.order_number} to #{order.status}",
          outlet: outlet
        ).call
      end

      return render ? render(json: order, each_serializer: order_serializer_class) : [true, order]
    end

    payload = order.errors
    render ? render(json: payload, status: :unprocessable_entity) : [false, payload]
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

  # Action methods below must be public (a `private` earlier is for internal helpers).
  public

  def grouped_orders_destroy
    # destroy orders with the same order number params[:order_number]
    orders = order_class.where(order_number: params[:order_number])
    if orders.destroy_all
      render json: { message: "Grouped orders deleted successfully" }, status: :ok
    else
      render json: { error: "Failed to delete grouped orders" }, status: :unprocessable_entity
    end
  end

  def pending_orders
    if current_user&.sephcocco_user_role&.name == "admin"
      orders = order_class.where(status: "pending")

      per_page = (params[:per_page] || 20).to_i
      page = (params[:page] || 1).to_i

      group_page = orders
                   .unscope(:order)
                   .distinct(false)
                   .group(:order_number)
                   .reorder(Arel.sql("MAX(#{order_class.table_name}.created_at) DESC"))
                   .select(:order_number)
                   .page(page)
                   .per(per_page)

      order_numbers = group_page.pluck(:order_number)
      orders = orders.where(order_number: order_numbers).order(created_at: :desc).to_a

      render json: {
        orders: ActiveModelSerializers::SerializableResource.new(
          GroupedOrdersCollection.new(orders: orders),
          serializer: grouped_orders_serializer_class,
          group_order_numbers: order_numbers
        ).as_json,
        meta: {
          total_count: group_page.total_count,
          total_pages: group_page.total_pages,
          current_page: group_page.current_page,
          per_page: group_page.limit_value
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
      orders = order_class.where(status: statuses)

      per_page = (params[:per_page] || 20).to_i
      page = (params[:page] || 1).to_i

      group_page = orders
                   .unscope(:order)
                   .distinct(false)
                   .group(:order_number)
                   .reorder(Arel.sql("MAX(#{order_class.table_name}.updated_at) DESC"))
                   .select(:order_number)
                   .page(page)
                   .per(per_page)

      order_numbers = group_page.pluck(:order_number)
      orders = orders.where(order_number: order_numbers).order(updated_at: :desc).to_a

      render json: {
        orders: ActiveModelSerializers::SerializableResource.new(
          GroupedOrdersCollection.new(orders: orders),
          serializer: grouped_orders_serializer_class,
          group_order_numbers: order_numbers
        ).as_json,
        meta: {
          total_count: group_page.total_count,
          total_pages: group_page.total_pages,
          current_page: group_page.current_page,
          per_page: group_page.limit_value
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
      orders = order_class.where(status: "delivering")

      per_page = (params[:per_page] || 20).to_i
      page = (params[:page] || 1).to_i

      group_page = orders
                   .unscope(:order)
                   .distinct(false)
                   .group(:order_number)
                   .reorder(Arel.sql("MAX(#{order_class.table_name}.updated_at) DESC"))
                   .select(:order_number)
                   .page(page)
                   .per(per_page)

      order_numbers = group_page.pluck(:order_number)
      orders = orders.where(order_number: order_numbers).order(updated_at: :desc).to_a

      render json: {
        orders: ActiveModelSerializers::SerializableResource.new(
          GroupedOrdersCollection.new(orders: orders),
          serializer: grouped_orders_serializer_class,
          group_order_numbers: order_numbers
        ).as_json,
        meta: {
          total_count: group_page.total_count,
          total_pages: group_page.total_pages,
          current_page: group_page.current_page,
          per_page: group_page.limit_value
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
      orders = order_class.where(status: "delivered")

      per_page = (params[:per_page] || 20).to_i
      page = (params[:page] || 1).to_i

      group_page = orders
                   .unscope(:order)
                   .distinct(false)
                   .group(:order_number)
                   .reorder(Arel.sql("MAX(#{order_class.table_name}.updated_at) DESC"))
                   .select(:order_number)
                   .page(page)
                   .per(per_page)

      order_numbers = group_page.pluck(:order_number)
      orders = orders.where(order_number: order_numbers).order(updated_at: :desc).to_a

      render json: {
        orders: ActiveModelSerializers::SerializableResource.new(
          GroupedOrdersCollection.new(orders: orders),
          serializer: grouped_orders_serializer_class,
          group_order_numbers: order_numbers
        ).as_json,
        meta: {
          total_count: group_page.total_count,
          total_pages: group_page.total_pages,
          current_page: group_page.current_page,
          per_page: group_page.limit_value
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

  # Admin order creation
  def admin_order_creation
    address = waiters_order_params[:address].to_s.strip
    normalized_address = address.downcase
    order_number = "#{normalized_address}#{DateTime.now.strftime("%Y%m%d%H%M%S")}"

    waiters_order_params[:products].each do |product|
      product_key = :"sephcocco_#{outlet.name.downcase}_product_id"
      product_id = product[product_key] || product[product_key.to_s]
      current_product = product_class.find_by(id: product_id)
      unless current_product
        return render json: { error: "Product not found" }, status: :unprocessable_entity
      end
  
      # check if product is out of stock
      amount_in_stock = current_product.amount_in_stock
      qty = (product[:quantity] || product["quantity"]).to_i
      if amount_in_stock == 0 || amount_in_stock < qty
        return render json: { error: "Product is out of stock, available stock is #{amount_in_stock}" }, status: :unprocessable_entity
      end
      
      unit_price = current_product.price
      customer = admin? ? @customer : current_user
      if customer.blank?
        return render json: { error: "sephcocco_user_id is required" }, status: :unprocessable_entity
      end

      order = customer.send(order_association).new(
        product_key => current_product.id,
        unit_price: unit_price,
        quantity: qty,
        address: normalized_address,
        additional_notes: waiters_order_params[:additional_notes],
        order_number: order_number
      )
      order.set_order_total(unit_price, qty)
      order.save!
      # add the order to the product (association name differs per outlet)
      current_product.public_send(product_class.order_association_name) << order
      # update the product stock
      current_product.amount_in_stock -= qty
      # increment the likes
      current_product.increment!(:likes)
      # save the product
      current_product.save!

      if admin?
        AdminNotifications::CreateService.new(
          action_type: "order",
          action_id: order.id,
          user: current_user,
          notification_class: admin_notification_class,
          outlet: outlet,
        ).call
      end
    end

    render json: { message: "Orders created successfully" }, status: :created
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
    
    if admin? && current_user.sephcocco_user_subroles.pluck(:name).exclude?("waiters")
      # For admin users, get customer from order params
      customer_id = order_params[:sephcocco_user_id] || current_user.id
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

  def grouped_orders_serializer_class
    outlet_name =
      if outlet.respond_to?(:name)
        outlet.name.to_s.downcase
      else
        outlet.to_s.downcase
      end

    case outlet_name
    when "lounge"
      Lounge::Admin::GroupedOrdersSerializer
    when "pharmacy"
      Pharmacy::Admin::GroupedOrdersSerializer
    when "restaurant"
      Restaurant::Admin::GroupedOrdersSerializer
    else
      # fallback (shouldn't happen)
      ActiveModel::Serializer
    end
  end
end
