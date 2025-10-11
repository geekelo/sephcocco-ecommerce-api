require 'net/http'
require 'uri'
require 'json'

module Api::V1::Concerns::PaymentsControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, only: [ :index, :create, :update, :destroy, :verify ]
    before_action :set_payment, only: [ :update, :destroy ]
    before_action :set_customer, only: [ :create ]
  end

  def index
    if current_user&.sephcocco_user_role&.name == "admin"
      payments = payment_class.all
    elsif current_user
      payments = current_user.send(payment_association).all
    else
      render json: { error: "Authentication required" }, status: :unauthorized
      return
    end

    # Apply filters if they exist
    if params[:filter].present?
      # Apply status filter
      if params[:filter][:status].present?
        payments = payments.where(status: params[:filter][:status])
      end
  
      # Apply date filter
      if params[:filter][:start_date].present? && params[:filter][:end_date].present?
        payments = payments.where(created_at: params[:filter][:start_date]..params[:filter][:end_date])
      elsif params[:filter][:start_date].present?
        payments = payments.where(created_at: params[:filter][:start_date]..Time.current)
      elsif params[:filter][:end_date].present?
        payments = payments.where(created_at: Time.current..params[:filter][:end_date])
      end
  
      # Apply payment method filter
      if params[:filter][:payment_method].present?
        payments = payments.where(payment_method: params[:filter][:payment_method])
      end

      # Apply department_id filter
      if params[:filter][:department_id].present?
        payments = payments.joins(:"sephcocco_#{outlet}_department")
        payments = payments.where(:"sephcocco_#{outlet}_department.id" => params[:filter][:department_id])
      end
  
      # Apply search_param filter
      if params[:filter][:search_terms].present?
        term = "%#{params[:filter][:search_terms]}%"
        payments = payments.joins(:sephcocco_user).where(
          "CAST(#{payment_class.table_name}.amount AS TEXT) ILIKE :term OR #{payment_class.table_name}.transaction_id ILIKE :term OR sephcocco_users.name ILIKE :term OR #{payment_class.table_name}.id::text ILIKE :term OR #{payment_class.table_name}.status ILIKE :term OR #{payment_class.table_name}.payment_method ILIKE :term OR orders::text ILIKE :term",
          term: term
        )
      end
    end

    # Sort by date
    payments = payments.order(created_at: :desc)

    # Apply pagination
    payments = payments.page(params[:page]).per(params[:per_page] || 20)

    render json: {
      payments: ActiveModelSerializers::SerializableResource.new(
        payments, 
        each_serializer: payment_serializer
      ).as_json,
      meta: {
        total_count: payments.total_count,
        total_pages: payments.total_pages,
        current_page: payments.current_page,
        per_page: payments.limit_value
      }
    }
  end

  def create
    order_ids = payment_params[:orders_ids]
    # Convert UUIDs to strings for the orders array field
    order_strings = order_ids&.map(&:to_s) || []
    actual_payment_params = payment_params.except(:orders_ids, :delivery_location_id).merge(orders: order_strings)
    order_total_price = 0
    delivery_price = 0

    if order_ids.present?
      order_ids.each do |order_id|
        begin
          order = order_class.find(order_id)
          product = product_class.find(order.send(:"sephcocco_#{outlet}_product_id"))
          
          # check if product is out of stock
          if product.amount_in_stock == 0 || product.amount_in_stock < order.quantity
            return render json: { error: "#{product.name} is out of stock, available stock is #{product.amount_in_stock}" }, status: :unprocessable_entity
          end
          order_total_price += order.total_price
        rescue ActiveRecord::RecordNotFound
          Rails.logger.error "Payment Create - Order not found: #{order_id} for outlet: #{outlet}"
          Rails.logger.error "Payment Create - All order IDs: #{order_ids.inspect}"
          Rails.logger.error "Payment Create - Order class: #{order_class.name}"
          return render json: { 
            error: "Order with ID #{order_id} not found or does not belong to #{outlet} outlet",
            order_id: order_id,
            outlet: outlet,
            order_class: order_class.name
          }, status: :unprocessable_entity
        end
      end
    else
      return render json: { error: "No orders found" }, status: :unprocessable_entity
    end

    # check if delivery location is present
    if payment_params[:delivery_location_id].present?
      delivery_location = SephcoccoLocation.find(payment_params[:delivery_location_id])
      delivery_price = delivery_location.logistics_price
    end

    # add delivery price to order total price
    order_total_price += delivery_price

    # Convert amount to BigDecimal for comparison
    payment_amount = BigDecimal(actual_payment_params[:amount].to_s)
    
    if payment_amount < order_total_price
      return render json: { error: "Amount is less than the order total price" }, status: :unprocessable_entity
    elsif payment_amount > order_total_price 
      return render json: { error: "Amount is greater than the order total price" }, status: :unprocessable_entity
    end

    # Debug logging
    Rails.logger.info "Payment Create - Order IDs: #{order_ids.inspect}"
    Rails.logger.info "Payment Create - Order Strings: #{order_strings.inspect}"
    Rails.logger.info "Payment Create - Actual Params: #{actual_payment_params.inspect}"
    if current_user&.sephcocco_user_role&.name == "admin"
      payment_params_hash = actual_payment_params.to_h
      payment = @customer&.send(payment_association)&.new(payment_params_hash) || payment_class.new(payment_params_hash)
      if payment.save
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "create",
          activity_name: "Payment",
          activity_description: "Payment Created: #{payment.id}",
          outlet: outlet
        ).call
        if order_ids.present?
          order_ids.each do |order_id|
            begin
              order = order_class.find(order_id)
              product = product_class.find(order.send(:"sephcocco_#{outlet}_product_id"))
              # update the payment id
              order.update("sephcocco_#{outlet}_payment_id" => payment.id)
            
              # update the product stock
              product.update!(amount_in_stock: product.amount_in_stock - order.quantity)
              product.save!
              if payment.status == "paid"
                order.change_order_status("awaiting payment approval")
              elsif payment.status == "payment confirmed"
                order.change_order_status("paid")
              end
              payment.orders << order
            rescue ActiveRecord::RecordNotFound
              Rails.logger.error "Payment Create - Order not found during update: #{order_id} for outlet: #{outlet}"
              # Continue with other orders even if one fails
            end
          end
        end
        render json: payment, each_serializer: payment_serializer, status: :created
      else
        render json: payment.errors, status: :unprocessable_entity
      end
    else
      # For non-admin users, we need to set the user_id
      payment_params_with_user = actual_payment_params.to_h.merge(sephcocco_user_id: current_user.id)
      Rails.logger.info "Payment Create - Final Params: #{payment_params_with_user.inspect}"
      Rails.logger.info "Payment Create - Current User ID: #{current_user.id}"
      Rails.logger.info "Payment Create - Payment Association: #{payment_association}"
      payment = current_user.send(payment_association).new(payment_params_with_user)
      Rails.logger.info "Payment Create - Payment Errors: #{payment.errors.full_messages}" unless payment.valid?
      if payment.save
        payment.update(delivery_location: { location: delivery_location.location, logistics_price: delivery_price })
        payment.save!
        AdminNotifications::CreateService.new(
          action_type: "payment",
          action_id: payment.id,
          user: current_user,
          notification_class: admin_notification_class,
          outlet: outlet
        ).call
        if order_ids.present?
          order_ids.each do |order_id|
            begin
              order = order_class.find(order_id)
              product = product_class.find(order.send(:"sephcocco_#{outlet}_product_id"))
              # update the payment id
              order.update("sephcocco_#{outlet}_payment_id" => payment.id)
              # update the product stock
              product.update!(amount_in_stock: product.amount_in_stock - order.quantity)
              product.save!
              if payment.status == "paid"
                order.change_order_status("awaiting payment approval")
              elsif payment.status == "payment confirmed"
                order.change_order_status("paid")
              end
              payment.orders << order
            rescue ActiveRecord::RecordNotFound
              Rails.logger.error "Payment Create - Order not found during update: #{order_id} for outlet: #{outlet}"
              # Continue with other orders even if one fails
            end
          end
        end

        # Initialize a transaction
        if params[:react_native].present?
          Rails.logger.info "Payment Create - React Native - Payment Valid: #{payment.valid?}"
          Rails.logger.info "Payment Create - React Native - Payment User: #{payment.sephcocco_user&.email}"
          Rails.logger.info "Payment Create - React Native - Payment Amount: #{payment.amount}"
          
          if payment.sephcocco_user.present?
            response = init(payment.sephcocco_user.email, payment.amount)
            payment.update(transaction_id: response["data"]["reference"])
            render json: { message: "Transaction initialized successfully", data: response }, status: :created
          else
            Rails.logger.error "Payment Create - React Native - Invalid payment or missing user"
            render json: { error: "Payment creation failed", errors: payment.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: payment, each_serializer: payment_serializer, status: :created
        end
      else
        render json: payment.errors, status: :unprocessable_entity
      end
    end
  end

  def update
    status = payment_params[:status] if payment_params[:status].present?
    if @payment.update(payment_params)
      if status.present?
        # Handle orders stored as array of IDs in JSONB field
        if @payment.orders.is_a?(Array) && @payment.orders.any?
          @payment.orders.each do |order_id|
            order = order_class.find_by(id: order_id)
            product = product_class.find(order.send(:"sephcocco_#{outlet}_product_id"))
            next unless order
            if status == "payment confirmed"
              # notify customer about the payment via email
              PaymentMailer.with(payment: @payment).payment_confirmed_email.deliver_now
              order.change_order_status("paid")

              @payment.sephcocco_user.update(payment_ref: @payment.sephcocco_user.payment_ref.next)
            elsif status == "cancelled"
              # notify customer about payment cancellation
              PaymentMailer.with(payment: @payment, reason: "Payment was cancelled").payment_failed_email.deliver_now
              order.change_order_status("payment cancelled")
              product.update!(amount_in_stock: product.amount_in_stock + order.quantity)
              product.save!
            elsif status == "paid"
              order.change_order_status("awaiting payment approval")
            elsif status == "declined"
              # notify customer about payment decline
              PaymentMailer.with(payment: @payment, reason: "Payment was declined").payment_declined_email.deliver_now
              order.change_order_status("payment declined")
              product.update!(amount_in_stock: product.amount_in_stock + order.quantity)
              product.save!
            elsif status == "failed"
              # notify customer about payment failure
              PaymentMailer.with(payment: @payment, reason: "Payment processing failed").payment_failed_email.deliver_now
              order.change_order_status("payment failed")
            end
          end
        end
      end
      
      if current_user&.sephcocco_user_role&.name == "admin"
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "update",
          activity_name: "Payment",
          activity_description: "Payment #{status}: #{@payment.id}",
          outlet: outlet
        ).call
        render json: @payment, each_serializer: payment_serializer
      else
        AdminNotifications::CreateService.new(
          action_type: "payment",
          action_id: @payment.id,
          user: current_user,
          notification_class: admin_notification_class,
          outlet: outlet
        ).call
        render json: @payment, each_serializer: payment_serializer
      end
    else
      render json: @payment.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @payment.destroy
      if admin?
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "delete",
          activity_name: "Payment",
          activity_description: "Payment Deleted: #{@payment.id}",
          outlet: outlet
        ).call
      else
        AdminNotifications::CreateService.new(
          action_type: "payment",
          action_id: @payment.id,
          user: current_user,
          notification_class: admin_notification_class,
          outlet: outlet
        ).call
      end
        render json: { message: "Payment deleted successfully" }, status: :ok
    else
        render json: { error: "Failed to delete payment" }, status: :unprocessable_entity
    end
  end

  def verify
    reference = params[:reference]

    if reference.blank?
      return render json: { error: 'Reference is required' }, status: :bad_request
    end

    Rails.logger.info "Payment verification - Reference: #{reference}"
    Rails.logger.info "Payment verification - PAYSTACK_SECRET_KEY present: #{ENV['PAYSTACK_SECRET_KEY'].present?}"

    uri = URI.parse("https://api.paystack.co/transaction/verify/#{reference}")
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{ENV['PAYSTACK_SECRET_KEY']}"

    Rails.logger.info "Payment verification - Making request to: #{uri}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    Rails.logger.info "Payment verification - Response code: #{response.code}"
    Rails.logger.info "Payment verification - Response body: #{response.body}"

    body = JSON.parse(response.body)
    Rails.logger.info "Payment verification response: #{body.inspect}"

    if body['status'] == true && body['data'] && body['data']['status'] == 'success'
      # ✅ Payment is verified and successful
      # Find the payment by reference and update it
      payment = payment_class.find_by(transaction_id: reference)
      
      if payment
        Rails.logger.info "Payment verified and confirmed: #{payment.id}"

        # check if payment amount paid is less than the order total price
        if body['data']['amount'] < payment.amount
          return render json: { error: "Payment amount does not match the order total price", data: body['data'] }, status: :unprocessable_entity
        end

        payment.update(status: "payment confirmed")
        # notify customer about the payment via email
        PaymentMailer.with(payment: payment).payment_confirmed_email.deliver_now
        
        # Handle orders - they might be stored as strings in a JSONB array
        if payment.orders.is_a?(Array) && payment.orders.any?
          payment.orders.each do |order_id|
            order = order_class.find_by(id: order_id)
            if order
              Rails.logger.info "Updating order status to payment confirmed: #{order_id}"
              order.change_order_status("paid")
            else
              Rails.logger.warn "Order not found with ID: #{order_id}"
            end
          end
        end
        
        payment.sephcocco_user.update(payment_ref: payment.sephcocco_user.payment_ref.next)
        
        # Create admin activity/notification
        if current_user&.sephcocco_user_role&.name == "admin"
          AdminActivities::CreateService.new(
            user: current_user,
            activity_type: "update",
            activity_name: "Payment",
            activity_description: "Payment verified and confirmed: #{payment.id}",
            outlet: outlet
          ).call
        else
          AdminNotifications::CreateService.new(
            action_type: "payment",
            action_id: payment.id,
            user: current_user,
            notification_class: admin_notification_class,
            outlet: outlet
          ).call
        end
        
        render json: { message: 'Payment verified and confirmed', data: body['data'], payment: payment }, status: :ok
      else
        render json: { error: 'Payment not found in database', data: body['data'] }, status: :not_found
      end
    else
      render json: { error: 'Payment verification failed', data: body['data'] }, status: :unprocessable_entity
    end
  rescue StandardError => e
    Rails.logger.error "Payment verification error: #{e.message}"
    Rails.logger.error "Payment verification error backtrace: #{e.backtrace.first(5).join("\n")}"
    render json: { error: e.message }, status: :internal_server_error
  end

  def update_delivery_location
    payment = payment_class.find(params[:id])
    delivery_location = params[:delivery_location_id]
    if delivery_location.present?
      delivery_location = SephcoccoLocation.find(delivery_location)
      delivery_price = delivery_location.logistics_price

      # update the payment amount
      previous_amount = payment.amount
      new_amount = (payment.amount - delivery_price).to_f + delivery_price
      payment.update(amount: new_amount.to_d, delivery_location: { location: delivery_location.location, logistics_price: delivery_price })
      payment.save!
    end
  end

  private

  def set_payment
    if current_user&.sephcocco_user_role&.name == "admin"
        @payment = payment_class.find(params[:id])
    else
        @payment = current_user.send(payment_association).find_by(id: params[:id])
    end
  end

  def set_customer
    if current_user&.sephcocco_user_role&.name == "admin"
      # For admin users, get customer from payment params
      customer_id = payment_params[:sephcocco_user_id]
      if customer_id.blank?
        Rails.logger.error "Admin payment creation: sephcocco_user_id is required"
        return
      end
      @customer = SephcoccoUser.find_by(id: customer_id)
      if @customer.nil?
        Rails.logger.error "Admin payment creation: Customer not found with ID #{customer_id}"
        return
      end
    else
      # For regular users, they are the customer
      @customer = current_user
    end
  end

  # Initialize a transaction for REACT NATIVE ONLY
  def init(email, amount)
    Rails.logger.info "Payment Create - Init - Email: #{email}"
    Rails.logger.info "Payment Create - Init - Amount: #{amount}"

    require 'net/http'
    require 'uri'
    require 'json'

    # Convert amount to kobo (Paystack expects amount in kobo)
    amount_in_kobo = (amount.to_f * 100).to_i
    Rails.logger.info "Payment Create - Init - Amount in Kobo: #{amount_in_kobo}"

    # Validate email format
    unless email.present? && email.include?('@')
      Rails.logger.error "Payment Create - Init - Invalid email: #{email}"
      return { "status" => false, "message" => "Invalid email address" }
    end

    # Validate amount
    if amount_in_kobo <= 0
      Rails.logger.error "Payment Create - Init - Invalid amount: #{amount_in_kobo}"
      return { "status" => false, "message" => "Invalid amount" }
    end

    uri = URI('https://api.paystack.co/transaction/initialize')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{ENV['PAYSTACK_SECRET_KEY']}"
    request['Content-Type'] = 'application/json'
    
    # Paystack request body with proper format
    request_body = {
      email: email,
      amount: amount_in_kobo,
      currency: "NGN",
      callback_url: "https://your-callback-url.com/callback" # You might want to make this configurable
    }
    
    request.body = request_body.to_json
    Rails.logger.info "Payment Create - Init - Request Body: #{request_body.inspect}"

    response = http.request(request)
    Rails.logger.info "Payment Create - Init - Response Code: #{response.code}"
    Rails.logger.info "Payment Create - Init - Response Body: #{response.body}"
    
    if response.code.to_i == 200
      parsed_response = JSON.parse(response.body)
      Rails.logger.info "Payment Create - Init - Parsed Response: #{parsed_response.inspect}"
      return parsed_response
    else
      Rails.logger.error "Payment Create - Init - Paystack API Error: #{response.code} - #{response.body}"
      return { "status" => false, "message" => "Paystack API error: #{response.code}" }
    end
  end

  def payment_class
      raise NotImplementedError, "You must implement the payment_class method"
  end

  def payment_params
      raise NotImplementedError, "You must implement the payment_params method"
  end

  def admin_notification_class
    raise NotImplementedError, "You must implement the admin_notification_class method"
  end
end
