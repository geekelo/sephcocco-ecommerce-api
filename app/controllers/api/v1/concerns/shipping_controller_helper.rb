# app/controllers/api/v1/concerns/shipping_controller_helper.rb
module Api::V1::Concerns::ShippingControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :set_shipping, only: [:show, :update, :destroy]
  end

  def index
    if current_user&.sephcocco_user_role&.name == "admin"
      shippings = shipping_class.all
    else
      shippings = current_user.send(shipping_association).all
    end

    # Apply filters
    if params[:filter].present?
      if params[:filter][:status].present?
        shippings = shippings.where(status: params[:filter][:status])
      end

        # Apply search
        if params[:filter][:search_terms].present?
          search_term = "%#{params[:filter][:search_terms]}%"
                                           shippings = shippings.joins(:"sephcocco_#{outlet}_order" => :sephcocco_user).where("tracking_number ILIKE ? OR rider ILIKE ? OR sephcocco_users.name ILIKE ? OR sephcocco_#{outlet}_orders.order_number ILIKE ?", search_term, search_term, search_term, search_term)
        end

        if params[:filter][:start_date].present? && params[:filter][:end_date].present?
          shippings = shippings.where(created_at: params[:filter][:start_date]..params[:filter][:end_date])
        elsif params[:filter][:start_date].present?
          shippings = shippings.where('created_at >= ?', params[:filter][:start_date])
        elsif params[:filter][:end_date].present?
          shippings = shippings.where('created_at <= ?', params[:filter][:end_date])
        end

    end

    # Apply pagination
    page_number = params[:page].is_a?(Hash) ? 1 : (params[:page] || 1)
    shippings = shippings.page(page_number).per(params[:per_page] || 20)

    render json: {
      shippings: ActiveModelSerializers::SerializableResource.new(
        shippings,
        each_serializer: shipping_serializer_class
      ).as_json,
      meta: {
        total_delivered: shippings.where(status: "delivered").count,
        total_in_transit: shippings.where(status: "in_transit").count,
        total_assigned: shippings.where(status: "assigned").count,
        total_pending: shippings.where(status: "pending").count,
        total_cancelled: shippings.where(status: "cancelled").count,
        total_dispatching: shippings.where(dispatching: true).count,
        total_count: shippings.total_count,
        total_pages: shippings.total_pages,
        current_page: shippings.current_page,
        per_page: shippings.limit_value
      }
    }
  end

  def show
    render json: @shipping, serializer: shipping_serializer_class
  end

  def create
    @shipping = shipping_class.new(shipping_params)
    
    if @shipping.save
      # Create admin activity/notification
      if current_user&.sephcocco_user_role&.name == "admin"
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "create",
          activity_name: "Logistics",
          activity_description: "Initiated Logistics with tracking number: #{@shipping.tracking_number}",
          outlet: outlet
        ).call
      else
        AdminNotifications::CreateService.new(
          action_type: "shipping",
          action_id: @shipping.id,
          user: current_user,
          notification_class: admin_notification_class,
          outlet: outlet
        ).call
      end

      render json: @shipping, serializer: shipping_serializer_class, status: :created
    else
      render json: { errors: @shipping.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    old_dispatching = @shipping.dispatching
    old_rider = @shipping.rider
    
    if @shipping.update(shipping_params)
      # Handle dispatching status change for location tracking
      handle_dispatching_status_change(old_dispatching, old_rider)
      
      # Create admin activity/notification
      if current_user&.sephcocco_user_role&.name == "admin"
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "update",
          activity_name: "Logistics",
          activity_description: "Logistics details updated with tracking number: #{@shipping.tracking_number}",
          outlet: outlet
        ).call
      else
        AdminNotifications::CreateService.new(
          action_type: "shipping",
          action_id: @shipping.id,
          user: current_user,
          notification_class: admin_notification_class,
          outlet: outlet
        ).call
      end

      render json: @shipping, serializer: shipping_serializer_class
    else
      render json: { errors: @shipping.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @shipping.destroy
      # Create admin activity
      if current_user&.sephcocco_user_role&.name == "admin"
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "delete",
          activity_name: "Logistics",
          activity_description: "Logistics deleted with tracking number: #{@shipping.tracking_number}",
          outlet: outlet
        ).call
      end

      render json: { message: "Logistics deleted successfully" }, status: :ok
    else
      render json: { error: "Failed to delete logistics" }, status: :unprocessable_entity
    end
  end

  # Custom actions
  def assign_rider
    @shipping = shipping_class.find(params[:id])
    rider = SephcoccoUser.find_by(id: params[:rider_id])
    if rider.nil?
      render json: { error: "Rider not found" }, status: :not_found
      return
    end
    if @shipping.update(rider: rider, status: "assigned")
      if current_user&.sephcocco_user_role&.name == "admin"
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "update",
          activity_name: "Logistics",
          activity_description: "Rider assigned for this delivery with tracking number: #{@shipping.tracking_number}",
          outlet: outlet
        ).call
      end
      # notify rider about the assignment
      ActionCable.server.broadcast(
        "rider_location_#{rider.id}",
        {
          type: 'rider_assigned',
          shipping_id: @shipping.id,
          tracking_number: @shipping.tracking_number,
          outlet_type: outlet,
          message: 'You have been assigned a new delivery with tracking number: #{@shipping.tracking_number}'
        }
      )
      render json: @shipping, serializer: shipping_serializer_class
    else
      render json: { errors: @shipping.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def start_delivery
    @shipping = shipping_class.find(params[:id])
    
    if @shipping.update(status: "in_transit", dispatching: true)
      render json: @shipping, serializer: shipping_serializer_class
    else
      render json: { errors: @shipping.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def complete_delivery
    @shipping = shipping_class.find(params[:id])
    
    if @shipping.update(status: "delivered", datetime_delivered: Time.current, dispatching: false)
      # Update orders status to delivered
      order = @shipping.send(order_association)
      if order.present?
        order.update(status: "delivered")
      end
      render json: @shipping, serializer: shipping_serializer_class
    else
      render json: { errors: @shipping.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def cancel_delivery
    @shipping = shipping_class.find(params[:id])
    
    if @shipping.update(status: "cancelled")
      # Update orders status to cancelled
      order = @shipping.send(order_association)
      if order.present?
        order.update(status: "cancelled")
      end
      render json: @shipping, serializer: shipping_serializer_class
    else
      render json: { errors: @shipping.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_shipping
    if current_user&.sephcocco_user_role&.name == "admin"
      @shipping = shipping_class.find(params[:id])
    else
      @shipping = current_user.send(shipping_association).find_by(id: params[:id])
    end
    
    unless @shipping
      render json: { error: "Shipping not found" }, status: :not_found
    end
  end

  def shipping_params
    params.require(:shipping).permit(
      :tracking_number,
      :status,
      :rider,
      :datetime_delivered,
      :dispatching,
      :sephcocco_pharmacy_order_id,
      :sephcocco_lounge_order_id,
      :sephcocco_restaurant_order_id
    )
  end

  # Abstract methods that must be implemented by each controller
  def shipping_class
    raise NotImplementedError, "Define `shipping_class` in your controller"
  end

  def shipping_association
    raise NotImplementedError, "Define `shipping_association` in your controller"
  end

  def shipping_serializer_class
    raise NotImplementedError, "Define `shipping_serializer_class` in your controller"
  end

  def admin_notification_class
    raise NotImplementedError, "Define `admin_notification_class` in your controller"
  end

  def outlet
    raise NotImplementedError, "Define `outlet` in your controller"
  end

  # Handle dispatching status changes for location tracking
  def handle_dispatching_status_change(old_dispatching, old_rider)
    # Check if dispatching status changed
    if @shipping.dispatching != old_dispatching
      if @shipping.dispatching == true
        # Rider started dispatching - enable location tracking
        enable_rider_location_tracking
      else
        # Rider stopped dispatching - disable location tracking
        disable_rider_location_tracking
      end
    end
    
    # Check if rider changed
    if @shipping.rider != old_rider && @shipping.rider.present?
      # New rider assigned - notify them to start location tracking
      notify_rider_assignment
    end
  end

  def enable_rider_location_tracking
    return unless @shipping.rider.present?
    
    Rails.logger.info "🚚 Enabling location tracking for rider: #{@shipping.rider.id}"
    
    # Notify rider to start location tracking
    ActionCable.server.broadcast(
      "rider_location_#{@shipping.rider.id}",
      {
        type: 'start_location_tracking',
        shipping_id: @shipping.id,
        tracking_number: @shipping.tracking_number,
        outlet_type: outlet,
        message: "Please start location tracking for this delivery with tracking number: #{@shipping.tracking_number}"
      }
    )
    
    # Notify admin about rider going online
    ActionCable.server.broadcast(
      "rider_locations_admin",
      {
        type: 'rider_online',
        rider_id: @shipping.rider.id,
        shipping_id: @shipping.id,
        outlet_type: outlet,
        timestamp: Time.current.iso8601
      }
    )
  end

  def disable_rider_location_tracking
    return unless @shipping.rider.present?
    
    Rails.logger.info "🚚 Disabling location tracking for rider: #{@shipping.rider.id}"
    
    # Notify rider to stop location tracking
    ActionCable.server.broadcast(
      "rider_location_#{@shipping.rider.id}",
      {
        type: 'stop_location_tracking',
        shipping_id: @shipping.id,
        message: "Location tracking stopped for this delivery with tracking number: #{@shipping.tracking_number}"
      }
    )
    
    # Notify admin about rider going offline
    ActionCable.server.broadcast(
      "rider_locations_admin",
      {
        type: 'rider_offline',
        rider_id: @shipping.rider.id,
        shipping_id: @shipping.id,
        outlet_type: outlet,
        timestamp: Time.current.iso8601
      }
    )
  end

  def notify_rider_assignment
    return unless @shipping.rider.present?
    
    Rails.logger.info "🚚 Notifying rider assignment: #{@shipping.rider.id}"
    
    # Notify the new rider about the assignment
    ActionCable.server.broadcast(
      "rider_location_#{@shipping.rider.id}",
      {
        type: 'rider_assigned',
        shipping_id: @shipping.id,
        tracking_number: @shipping.tracking_number,
        outlet_type: outlet,
        message: "You have been assigned a new delivery with tracking number: #{@shipping.tracking_number}"
      }
    )
  end
end 