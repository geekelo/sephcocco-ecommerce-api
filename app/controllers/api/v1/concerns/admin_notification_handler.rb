# app/controllers/concerns/pharmacy_admin_notification_handler.rb
module Api::V1::Concerns::AdminNotificationHandler
  extend ActiveSupport::Concern

  included do
    before_action :set_notification, only: [:update]
  end

  def index_notifications(model)
    notifications = model.where(viewed: false)
    render json: notifications, status: :ok
  end

  def update_notification
    Rails.logger.info "Updating notification: #{@notification.inspect}"
    Rails.logger.info "Notification params: #{notification_params.inspect}"
    
    if @notification.update(notification_params)
      render json: @notification, status: :ok
    else
      Rails.logger.error "Failed to update notification: #{@notification.errors.full_messages}"
      render json: { errors: @notification.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_notification
    @notification = controller_name_class.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Notification not found' }, status: :not_found
  end

  def notification_params
    params.require(param_key).permit(:viewed)
  end
end
