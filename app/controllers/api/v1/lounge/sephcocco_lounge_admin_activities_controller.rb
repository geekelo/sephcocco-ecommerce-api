class Api::V1::Lounge::SephcoccoLoungeAdminActivitiesController < ApplicationController
  include Api::V1::Concerns::AdminActivityControllerHelper

  def admin_activity_class
    Lounge::SephcoccoLoungeAdminActivity
  end

  def admin_activity_serializer_class
    Lounge::Admin::SephcoccoLoungeAdminActivitySerializer
  end

  def outlet
    "lounge"
  end
end
