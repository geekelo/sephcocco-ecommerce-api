module Api::V1::Concerns::FaqsControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  def index
    category_association = :"sephcocco_#{outlet}_faq_category"
    
    faqs = if admin?
      faq_class.includes(category_association).order(:position)
    else
      faq_class.includes(category_association).where(visibility: true).order(:position)
    end

    faqs = faqs.order(created_at: :desc)

    render json: faqs, each_serializer: faq_serializer_class
  end

  def create
    # Setting these values because they are not required on the FE ATM
    category_key = :"sephcocco_#{outlet}_faq_category_id"
    all_category = ensure_all_category_exists
    
    # Create a new params hash with the additional values
    service_params = faq_params.to_h.merge(
      category_key => all_category.id,
      visibility: true,
      position: 1
    )

    faq = Faqs::CreateService.new(
      user: current_user,
      params: service_params,
      faq_class: faq_class,
      outlet: outlet
    ).call

    if admin?
      AdminActivities::CreateService.new(
        user: current_user,
        activity_type: "Create",
        activity_name: "FAQ",
        activity_description: "FAQ Created: #{faq.title}",
        outlet: outlet
      ).call
    end
    render json: faq, serializer: faq_serializer_class, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def update
    # Clean the ID if it has the "id=" prefix
    faq_id = params[:id].to_s.gsub('id=', '')
    
    faq = Faqs::UpdateService.new(
      user: current_user,
      faq_id: faq_id,
      params: faq_params,
      faq_class: faq_class,
      outlet: outlet
    ).call

    if admin?
      AdminActivities::CreateService.new(
        user: current_user,
        activity_type: "Update",
        activity_name: "FAQ",
        activity_description: "FAQ Updated: #{faq.title}",
        outlet: outlet
      ).call
    end

    render json: faq, serializer: faq_serializer_class
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "FAQ Controller - FAQ not found: #{e.message}"
    render json: { error: "Not authorized or FAQ not found" }, status: :forbidden
  rescue ActiveRecord::RecordInvalid => e
    render json: e.record.errors, status: :unprocessable_entity
  end

  def destroy
    faq = faq_class.find(params[:id])
    faq.destroy
    if admin?
      AdminActivities::CreateService.new(
        user: current_user,
        activity_type: "Delete",
        activity_name: "FAQ",
        activity_description: "FAQ Deleted: #{faq.title}",
        outlet: outlet
      ).call
    end
    render json: { message: "FAQ deleted" }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "FAQ not found" }, status: :not_found
  end

  private

  def admin?
    current_user.sephcocco_user_role.name == "admin"
  end

  def ensure_all_category_exists
    all_category = faq_category_class.find_by(title: "all")
    
    if all_category.nil?
      # Create the "all" category if it doesn't exist
      all_category = faq_category_class.create!(
        title: "all",
        description: "General FAQ category for all #{outlet}-related questions",
        visibility: true,
        position: 1
      )
    end
    
    all_category
  end
end
