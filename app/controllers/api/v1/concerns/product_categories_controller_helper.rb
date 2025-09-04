# app/controllers/api/v1/concerns/product_categories_controller_helper.rb
module Api::V1::Concerns::ProductCategoriesControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, only: [ :create, :update, :destroy ]
    before_action :set_product_category, only: [ :show, :update, :destroy ]
  end

  def index
    categories = category_class.all
    categories = categories.order(created_at: :desc)
    render json: categories, each_serializer: product_category_unnested_serializer
  end

  def show
    render json: @product_category, serializer: product_category_serializer
  end

  def create
    @product_category = category_class.new(product_category_params)

    if @product_category.save
      if admin?
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "create",
          activity_name: "Product Category",
          activity_description: "Product Category Created: #{@product_category.name}",
          outlet: outlet
        ).call
      end
      render json: @product_category, serializer: product_category_serializer, status: :created
    else
      render json: @product_category.errors, status: :unprocessable_entity
    end
  end

  def update
    if @product_category.update(product_category_params)
      if admin?
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "update",
          activity_name: "Product Category",
          activity_description: "Product Category Updated: #{@product_category.name}",
          outlet: outlet
        ).call
      end
      render json: @product_category, serializer: product_category_serializer
    else
      render json: @product_category.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @product_category.destroy
    if admin?
      AdminActivities::CreateService.new(
        user: current_user,
        activity_type: "delete",
        activity_name: "Product Category",
        activity_description: "Product Category Deleted: #{@product_category.name}",
        outlet: outlet
      ).call
    end
    render json: { message: "Category deleted" }, status: :ok
  end

  def add_product_to_category
    product = product_class.find_by(id: params[:product_id])
    category = category_class.find_by(id: params[:category_id])

    if product && category
      association = product.send(product_category_association_name)
      association << category unless association.include?(category)

      if admin?
        AdminActivities::CreateService.new(
          user: current_user,
          activity_type: "update",
          activity_name: "Product Category",
          activity_description: "Product Category Updated: #{product.name}",
          outlet: outlet
        ).call
      end

      render json: { message: "Product added to category successfully", product: product }, status: :created
    else
      render json: { message: "Product or category not found" }, status: :not_found
    end
  end

  private

  def admin?
    current_user.sephcocco_user_role.name == "admin"
  end

  def set_product_category
    @product_category = category_class.find(params[:id])
  end
end
