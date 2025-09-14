# app/controllers/concerns/pharmacy_admin_notification_handler.rb
module Api::V1::Concerns::AdminNotificationHandler
  extend ActiveSupport::Concern

  included do
    before_action :set_notification, only: [:update]
  end

  def index_notifications(model)
    notifications = model.where(viewed: false).order(created_at: :desc)
    render json: notifications, status: :ok
  end

  def update_notification
    if @notification.update(notification_params)
      if admin?
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "update",
          activity_name: "Notification",
          activity_description: "Notification Viewed: #{@notification.message}",
          outlet: outlet
        ).call
      end
      render json: @notification, status: :ok
    else
      render json: { errors: @notification.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_notification
    @notification = controller_name.classify.constantize.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Notification not found' }, status: :not_found
  end

  def notification_params
    params.require(param_key).permit(:viewed)
  end

  def admin?
    current_user&.sephcocco_user_role&.name == "admin"
  end
end
