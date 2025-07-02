module Api::V1::Concerns::FaqsControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  def create
    # Setting these values because they are not required on the FE ATM
    category_key = :"sephcocco_#{outlet}_faq_category_id"
    faq_params[category_key] = faq_category_class.find_by(title: "all").id
    faq_params[:visibility] = true
    faq_params[:position] = 1

    faq = Faqs::CreateService.new(
      user: current_user,
      params: faq_params,
      message_class: message_class,
      outlet: outlet
    ).call

    render json: faq, serializer: faq_serializer_class, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: e.record.errors, status: :unprocessable_entity
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
end
