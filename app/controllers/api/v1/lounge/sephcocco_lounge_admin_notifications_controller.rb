class Api::V1::Lounge::SephcoccoLoungeAdminNotificationsController < ApplicationController
  include Api::V1::Concerns::AdminNotificationHandler
  
  def index
    index_notifications(Lounge::SephcoccoLoungeAdminNotification)
  end

  def update
    update_notification
  end

  def controller_name_class
    "Lounge::SephcoccoLoungeAdminNotification"
  end

  def param_key
    "sephcocco_lounge_admin_notification"
  end
end
