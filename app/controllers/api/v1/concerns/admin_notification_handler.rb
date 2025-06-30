# app/controllers/concerns/pharmacy_admin_notification_handler.rb
module Api::V1::Concerns::PharmacyAdminNotificationHandler
  extend ActiveSupport::Concern

  included do
    before_action :set_notification, only: [:update]
  end

  def index_notifications(model)
    notifications = model.where(visible: true)
    render json: notifications, status: :ok
  end

  def update_notification
    if @notification.update(notification_params)
      render json: @notification, status: :ok
    else
      render json: { errors: @notification.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_notification
    @notification = controller_name.classify.constantize.find(params[:id])
  end

  def notification_params
    params.require(controller_name.singularize.to_sym).permit(:viewed)
  end
end
