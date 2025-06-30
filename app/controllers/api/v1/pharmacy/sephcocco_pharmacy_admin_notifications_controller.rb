class Api::V1::Pharmacy::SephcoccoPharmacyAdminNotificationsController < ApplicationController
  include Api::V1::Concerns::AdminNotificationHandler

  def index
    index_notifications(Pharmacy::SephcoccoPharmacyAdminNotification)
  end

  def update
    update_notification
  end

  def controller_name
    "Pharmacy::SephcoccoPharmacyAdminNotification"
  end

  def param_key
    "sephcocco_pharmacy_admin_notification"
  end
end
