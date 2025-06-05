class Api::V1::Restaurant::SephcoccoRestaurantAdminNotificationsController < ApplicationController
  def index
    notifications = SephcoccoRestaurantAdminNotification.where(visible: true).all
    render json: notifications, status: :ok
  end

  def update
    notification = SephcoccoRestaurantAdminNotification.find(params[:id])

    if notification.update(notification_params)
      render json: notification, status: :ok
    else
      render json: { errors: notification.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def notification_params
    params.require(:sephcocco_restaurant_admin_notification).permit(:viewed)
  end
end
