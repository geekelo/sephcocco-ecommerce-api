module Api::V1::Concerns::FaqsControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
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
      message_class: message_class,
      outlet: outlet
    ).call

    render json: faq, serializer: faq_serializer_class, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def update
    faq = Faqs::UpdateService.new(
      user: current_user,
      faq_id: params[:id],
      params: faq_params,
      message_class: message_class,
      outlet: outlet
    ).call

    render json: faq, serializer: faq_serializer_class
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Not authorized or FAQ not found" }, status: :forbidden
  rescue ActiveRecord::RecordInvalid => e
    render json: e.record.errors, status: :unprocessable_entity
  end

  def destroy
    faq = message_class.find(params[:id])
    faq.destroy
    render json: { message: "FAQ deleted" }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "FAQ not found" }, status: :not_found
  end

  private

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
