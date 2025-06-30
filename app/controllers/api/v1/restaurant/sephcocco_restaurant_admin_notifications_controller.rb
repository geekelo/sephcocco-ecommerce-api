class Api::V1::Restaurant::SephcoccoRestaurantAdminNotificationsController < ApplicationController
  include Api::V1::Concerns::AdminNotificationHandler

  def index
    index_notifications(SephcoccoPharmacyAdminNotification)
  end

  def update
    update_notification
  end

  def controller_name
    "Restaurant::SephcoccoRestaurantAdminNotification"
  end
end
