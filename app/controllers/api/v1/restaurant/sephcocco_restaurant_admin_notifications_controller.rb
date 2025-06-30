class Api::V1::Restaurant::SephcoccoRestaurantAdminNotificationsController < ApplicationController
  include Api::V1::Concerns::AdminNotificationHandler

  def index
    index_notifications(Restaurant::SephcoccoRestaurantAdminNotification)
  end

  def update
    update_notification
  end

  def controller_name
    "Restaurant::SephcoccoRestaurantAdminNotification"
  end

  def param_key
    "sephcocco_restaurant_admin_notification"
  end
end
