# app/controllers/api/v1/sephcocco_lounge_product_categories_controller.rb
class Api::V1::Lounge::SephcoccoLoungeProductCategoriesController < ApplicationController
  include Api::V1::Concerns::ProductCategoriesControllerHelper

  private

  def category_class
    SephcoccoLoungeProductCategory
  end

  def product_class
    SephcoccoLoungeProduct
  end

  def product_category_association_name
    :sephcocco_lounge_product_categories
  end

  def product_category_params
    params.require(:product_category).permit(:name, :description, :slug)
  end
end
