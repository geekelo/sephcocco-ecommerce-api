# app/controllers/api/v1/concerns/product_manageable.rb
module Api::V1::Concerns::ProductsControllerHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, only: [:create, :update, :destroy, :switch_visibility, :like, :unlike]
    before_action :set_product, only: [:show, :update, :destroy, :switch_visibility, :like, :unlike]
  end

  def index
    products = product_class.all
    if current_user.sephcocco_user_role.name == 'admin'
      render json: products, each_serializer: Lounge::Admin::SephcoccoLoungeProductSerializer
    else
      render json: products, each_serializer: Lounge::User::SephcoccoLoungeProductSerializer
    end
  end

  def show
    render json: @product
  end

  def create
    @product = product_class.new(product_params)

    if product_params[:category_ids].present?
      @product.send(category_association_name).replace(category_class.where(id: product_params[:category_ids]))
    end

    if @product.save
      if current_user.sephcocco_user_role.name == 'admin'
        render json: @product, serializer: Lounge::Admin::SephcoccoLoungeProductSerializer, status: :created
      else
        render json: @product, serializer: Lounge::User::SephcoccoLoungeProductSerializer, status: :created
      end
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      if current_user.sephcocco_user_role.name == 'admin'
        render json: @product, serializer: Lounge::Admin::SephcoccoLoungeProductSerializer
      else
        render json: @product, serializer: Lounge::User::SephcoccoLoungeProductSerializer
      end
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    render json: { message: 'Product deleted successfully' }, status: :ok
  end

  def switch_visibility
    @product.update(visible: !@product.visible)
    serializer = Lounge::Admin::SephcoccoLoungeProductSerializer if current_user.sephcocco_user_role.name == 'admin'

  render json: {
    message: "Product visibility updated successfully",
    product: serializer.new(@product)
  }
  end

  def like
    unless like_class.exists?(product_key => @product.id, user_key => current_user.id)
      @product.increment!(:likes)
      like_class.create(user_key => current_user.id, product_key => @product.id)
      serializer = Lounge::User::SephcoccoLoungeProductSerializer if current_user.sephcocco_user_role.name == 'user'
      render json: { message: "Product liked successfully", product: serializer.new(@product) }, status: :created
    else
      render json: { message: "Product already liked" }, status: :unprocessable_entity
    end
  end

  def unlike
    if @product.likes > 0
      if like_class.exists?(product_key => @product.id, user_key => current_user.id)
        like_class.where(product_key => @product.id, user_key => current_user.id).destroy_all
        @product.decrement!(:likes)
        serializer = Lounge::User::SephcoccoLoungeProductSerializer if current_user.sephcocco_user_role.name == 'user'
        render json: { message: "Product unliked successfully", product: serializer.new(@product) }, status: :ok
      else
        render json: { message: "Product not liked by user" }, status: :unprocessable_entity
      end
    else
      render json: { message: "Product cannot be unliked, no likes to remove" }, status: :unprocessable_entity
    end
  end

  private

  def set_product
    @product = product_class.find(params[:id])
  end

  # The following methods must be overridden in each specific controller:
  def product_class; raise NotImplementedError; end
  def category_class; raise NotImplementedError; end
  def like_class; raise NotImplementedError; end
  def product_key; raise NotImplementedError; end
  def user_key; raise NotImplementedError; end
  def category_association_name; raise NotImplementedError; end
end
