class Api::V1::Pharmacy::Outlet1PharmacyAdminNotificationsController < ApplicationController
  include Api::V1::Concerns::AdminNotificationHandler

  def index
    index_notifications(SephcoccoPharmacyAdminNotification)
  end

  def update
    update_notification
  end

  def controller_name
    "sephcocco_pharmacy_admin_notification"
  end
end
