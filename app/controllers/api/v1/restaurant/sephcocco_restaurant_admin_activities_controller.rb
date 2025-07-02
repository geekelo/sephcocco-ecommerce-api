class Api::V1::Restaurant::SephcoccoRestaurantAdminActivitiesController < ApplicationController
  include Api::V1::Concerns::AdminActivityController
    
  def admin_activity_class
    Restaurant::SephcoccoRestaurantAdminActivity
  end
    
  def admin_activity_serializer_class
    Restaurant::Admin::SephcoccoRestaurantAdminActivitySerializer
  end
    
  def outlet
    "Restaurant"
  end
end
     