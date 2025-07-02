class Api::V1::Pharmacy::SephcoccoPharmacyAdminActivitiesController < ApplicationController
  include Api::V1::Concerns::AdminActivityControllerHelper

  def admin_activity_class
    Pharmacy::SephcoccoPharmacyAdminActivity
  end

  def admin_activity_serializer_class
    Pharmacy::Admin::SephcoccoPharmacyAdminActivitySerializer
  end

  def outlet
    "pharmacy"
  end
end
  