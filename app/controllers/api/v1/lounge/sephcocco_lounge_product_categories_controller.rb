# app/controllers/api/v1/sephcocco_lounge_product_categories_controller.rb
class Api::V1::Lounge::SephcoccoLoungeProductCategoriesController < ApplicationController
  include Api::V1::Concerns::ProductCategoriesControllerHelper

  private

  def category_class
    Lounge::SephcoccoLoungeProductCategory
  end

  def product_class
    Lounge::SephcoccoLoungeProduct
  end

  def product_category_unnested_serializer
    Lounge::SephcoccoLoungeProductCategorySerializer
  end

  def product_category_serializer
    if current_user.sephcocco_user_role.name == "admin"
      Lounge::Admin::SephcoccoLoungeProductCategorySerializer
    else
      Lounge::User::SephcoccoLoungeProductCategorySerializer
    end
  end

  def product_category_association_name
    :sephcocco_lounge_product_categories
  end

  def product_category_params
    params.require(:product_category).permit(:name, :description, :slug)
  end
end
