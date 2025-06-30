class Api::V1::Lounge::SephcoccoLoungeAdminNotificationsController < ApplicationController
  include Api::V1::Concerns::AdminNotificationHandler
  
  def index
    index_notifications(SephcoccoPharmacyAdminNotification)
  end

  def update
    update_notification
  end

  def controller_name
    "Lounge::SephcoccoLoungeAdminNotification"
  end
end
