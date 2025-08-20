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
    shippings = shippings.where(status: params[:status]) if params[:status].present?
    shippings = shippings.where(dispatching: params[:dispatching]) if params[:dispatching].present?
    shippings = shippings.where(rider: params[:rider]) if params[:rider].present?

    # Apply search
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      shippings = shippings.where("tracking_number ILIKE ? OR rider ILIKE ?", search_term, search_term)
    end

    # Apply pagination
    shippings = shippings.page(params[:page]).per(params[:per_page] || 20)

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
          activity_type: "Create",
          activity_name: "Shipping",
          activity_description: "Shipping created: #{@shipping.id}",
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
    if @shipping.update(shipping_params)
      # Create admin activity/notification
      if current_user&.sephcocco_user_role&.name == "admin"
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "Update",
          activity_name: "Shipping",
          activity_description: "Shipping updated: #{@shipping.id}",
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
          activity_type: "Delete",
          activity_name: "Shipping",
          activity_description: "Shipping deleted: #{@shipping.id}",
          outlet: outlet
        ).call
      end

      render json: { message: "Shipping deleted successfully" }, status: :ok
    else
      render json: { error: "Failed to delete shipping" }, status: :unprocessable_entity
    end
  end

  # Custom actions
  def assign_rider
    @shipping = shipping_class.find(params[:id])
    
    if @shipping.update(rider: params[:rider], status: "assigned")
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
end 