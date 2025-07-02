class Api::V1::Lounge::SephcoccoLoungeAdminActivitiesController < ApplicationController
  include Api::V1::Concerns::AdminActivityController

  def admin_activity_class
    Lounge::SephcoccoLoungeAdminActivity
  end

  def admin_activity_serializer_class
    Lounge::Admin::SephcoccoLoungeAdminActivitySerializer
  end

  def outlet
    "Lounge"
  end
end
