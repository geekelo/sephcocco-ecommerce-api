module Api::V1::Concerns::FaqCategoriesControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :authorize_admin!, except: [ :index, :show ]
    before_action :set_faq_category, only: %i[show update destroy switch_visibility]
  end

  def index
    if current_user.sephcocco_user_role.name == "admin"
      faq_categories = faq_category_class.all
      render json: faq_categories, each_serializer: faq_category_serializer
    else
      faq_categories = faq_category_class.where(visibility: true)
      render json: faq_categories, each_serializer: faq_category_serializer
    end
  end

  def show
    render json: @faq_category, serializer: faq_category_serializer
  end

  def create
    faq_category = faq_category_class.new(faq_category_params)
    if faq_category.save
      render json: faq_category, status: :created, serializer: faq_category_serializer
    else
      render json: faq_category.errors, status: :unprocessable_entity
    end
  end

  def update
    if @faq_category.update(faq_category_params)
      render json: @faq_category, serializer: faq_category_serializer
    else
      render json: @faq_category.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @faq_category.destroy
      render json: { message: "FAQ Category deleted successfully" }, status: :ok
    else
      render json: { error: "Failed to delete FAQ Category" }, status: :unprocessable_entity
    end
  end

  def switch_visibility
    @faq_category.visibility = !@faq_category.visibility
    if @faq_category.save
      render json: { message: "FAQ Category visibility updated successfully" }, status: :ok
    else
      render json: { error: "Failed to update FAQ Category visibility" }, status: :unprocessable_entity
    end
  end

  def update_position
    faq_category_class.transaction do
      params[:faq_categories].each do |category_params|
        category = faq_category_class.find(category_params[:id])
        category.update!(position: category_params[:position])
      end
      render json: { message: "FAQ Categories positions updated successfully" }, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  private

  def authorize_admin!
    unless current_user&.sephcocco_user_role&.name == "admin"
      render json: { message: "Unauthorized" }, status: :unauthorized
    end
  end

  def set_faq_category
    @faq_category = faq_category_class.find(params[:id])
  end
end
