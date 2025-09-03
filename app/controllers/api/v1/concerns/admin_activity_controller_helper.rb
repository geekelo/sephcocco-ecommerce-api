module Api::V1::Concerns::AdminActivityControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  def index
    # spot for RBAC to give activities for the admin only or all to managers
    admin_activities = if admin?
      admin_activity_class.all
    else
      admin_activity_class.where(sephcocco_user_id: current_user.id)
    end

    if params[:filter]
      # Filter by activity type
      if params[:filter][:activity_type].present?
        admin_activities = admin_activities.where(activity_type: params[:filter][:activity_type])
      end

      # Filter by activity name
      if params[:filter][:activity_name].present?
        admin_activities = admin_activities.where(activity_name: params[:filter][:activity_name])
      end

      # Search in activity description and other fields
      if params[:filter][:search_terms].present?
        search_term = "%#{params[:filter][:search_terms]}%"
        admin_activities = admin_activities.where(
          "activity_description ILIKE ? OR activity_type ILIKE ? OR activity_name ILIKE ? OR sephcocco_users.name ILIKE ?",
          search_term, search_term, search_term, search_term
        )
      end

      # Filter by date range
      if params[:filter][:start_date].present? && params[:filter][:end_date].present?
        admin_activities = admin_activities.where(created_at: params[:filter][:start_date]..params[:filter][:end_date])
      elsif params[:filter][:start_date].present?
        admin_activities = admin_activities.where('created_at >= ?', params[:filter][:start_date])
      elsif params[:filter][:end_date].present?
        admin_activities = admin_activities.where('created_at <= ?', params[:filter][:end_date])
      end
    end    
    admin_activities = admin_activities.order(created_at: :desc)
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

  private

  def admin?
    current_user.sephcocco_user_role.name == "admin"
  end
end