# app/controllers/api/v1/concerns/product_categories_controller_helper.rb
module Api::V1::Concerns::ProductCategoriesControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, only: [:create, :update, :destroy]
    before_action :set_product_category, only: [:show, :update, :destroy]
  end

  def index
    categories = category_class.all
    render json: categories
  end

  def show
    render json: @product_category
  end

  def create
    @product_category = category_class.new(product_category_params)

    if @product_category.save
      render json: @product_category, status: :created
    else
      render json: @product_category.errors, status: :unprocessable_entity
    end
  end

  def update
    if @product_category.update(product_category_params)
      render json: @product_category
    else
      render json: @product_category.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @product_category.destroy
    render json: { message: 'Category deleted' }, status: :ok
  end

  def add_product_to_category
    product = product_class.find_by(id: params[:product_id])
    category = category_class.find_by(id: params[:category_id])

    if product && category
      association = product.send(product_category_association_name)
      association << category unless association.include?(category)

      render json: { message: "Product added to category successfully", product: product }, status: :created
    else
      render json: { message: "Product or category not found" }, status: :not_found
    end
  end

  private

  def set_product_category
    @product_category = category_class.find(params[:id])
  end
end
