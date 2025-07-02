class Api::V1::Concerns::AdminActivityController < ApplicationController
  before_action :authenticate_user!

  def index
    # spot for RBAC to give activities for the admin only or all to managers
    admin_activities = if admin?
      admin_activity_class.all
    else
      admin_activity_class.where(sephcocco_user_id: current_user.id)
    end
    
    admin_activities = admin_activities.page(params[:page]).per(params[:per_page] || 20)
    
    render json: {
        admin_activities: ActiveModelSerializers::SerializableResource.new(
            admin_activities,
            each_serializer: admin_activity_serializer_class
        ).as_json,
        meta: {
            total_count: admin_activities.total_count,
            total_pages: admin_activities.total_pages,
            current_page: admin_activities.current_page
        }
    }
  end
  
  def admin?
    current_user.sephcocco_user_role.name == "admin"
  end
end