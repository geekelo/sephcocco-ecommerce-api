module Api::V1::Concerns::FaqsControllerHelper
  include ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  def create
    faq = Lounge::Faqs::CreateService.new(
      user: current_user,
      params: faq_params,
      message_class: message_class
    ).call

    render json: faq, serializer: faq_serializer_class, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: e.record.errors, status: :unprocessable_entity
  end

  def update
    faq = Lounge::Faqs::UpdateService.new(
      user: current_user,
      faq_id: params[:id],
      params: faq_params,
      message_class: message_class
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
