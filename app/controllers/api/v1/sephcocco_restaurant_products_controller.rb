# app/controllers/api/v1/sephcocco_restaurant_products_controller.rb
class Api::V1::SephcoccoRestaurantProductsController < ApplicationController
  include Api::V1::Concerns::ProductManageable

  private

  def product_class
    SephcoccoRestaurantProduct
  end

  def category_class
    SephcoccoRestaurantProductCategory
  end

  def like_class
    SephcoccoRestaurantProductLike
  end

  def product_key
    :sephcocco_restaurant_product_id
  end

  def user_key
    :sephcocco_user_id
  end

  def category_association_name
    :sephcocco_restaurant_product_categories
  end

  def product_params
    params.require(:product).permit(
      :name,
      :short_description,
      :long_description,
      :image_url,
      :other_images,
      :amount_in_stock,
      :price,
      :visible,
      category_ids: []
    )
  end
end
