# app/controllers/api/v1/sephcocco_restaurant_products_controller.rb
class Api::V1::Restaurant::SephcoccoRestaurantProductsController < ApplicationController
  include Api::V1::Concerns::ProductsControllerHelper

  private

  def product_class
    Restaurant::SephcoccoRestaurantProduct
  end

  def category_class
    Restaurant::SephcoccoRestaurantProductCategory
  end

  def like_class
    Restaurant::SephcoccoRestaurantProductLike
  end

  def product_key
    :sephcocco_restaurant_product_id
  end

  def unnested_product_serializer
    Restaurant::SephcoccoRestaurantProductSerializer
  end

  def product_serializer
    if current_user&.sephcocco_user_role&.name == "admin"
      Restaurant::Admin::SephcoccoRestaurantProductSerializer
    elsif current_user&.sephcocco_user_role&.name == "user"
      Restaurant::User::SephcoccoRestaurantProductSerializer
    else
      Restaurant::SephcoccoRestaurantProductSerializer
    end
  end

  def user_key
    :sephcocco_user_id
  end

  def category_association_name
    :sephcocco_restaurant_product_categories
  end

  def outlet
    "restaurant"
  end

  def admin_notification_class
    Restaurant::SephcoccoRestaurantAdminNotification
  end

  def product_params
    params.require(:product).permit(
      :name,
      :short_description,
      :long_description,
      :main_image_url,
      :amount_in_stock,
      :price,
      :visible,
      :barcode,
      category_ids: [],
      other_image_urls: []
    )
  end
end
