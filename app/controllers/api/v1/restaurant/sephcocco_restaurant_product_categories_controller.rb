# app/controllers/api/v1/sephcocco_restaurant_product_categories_controller.rb
class Api::V1::Restaurant::SephcoccoRestaurantProductCategoriesController < ApplicationController
  include Api::V1::Concerns::ProductCategoriesControllerHelper

  private

  def category_class
    SephcoccoRestaurantProductCategory
  end

  def product_class
    SephcoccoRestaurantProduct
  end

  def product_category_unnested_serializer
    Restaurant::SephcoccoRestaurantProductCategorySerializer
  end

  def product_category_serializer
    if current_user.sephcocco_user_role.name == "admin"
      Restaurant::Admin::SephcoccoRestaurantProductCategorySerializer
    else
      Restaurant::User::SephcoccoRestaurantProductCategorySerializer
    end
  end

  def product_category_association_name
    :sephcocco_restaurant_product_categories
  end

  def product_category_params
    params.require(:product_category).permit(:name, :description, :slug)
  end
end
