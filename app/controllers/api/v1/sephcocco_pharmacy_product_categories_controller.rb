# app/controllers/api/v1/sephcocco_pharmacy_product_categories_controller.rb
class Api::V1::SephcoccoPharmacyProductCategoriesController < ApplicationController
  include Api::V1::Concerns::ProductCategorizable

  private

  def category_class
    SephcoccoPharmacyProductCategory
  end

  def product_class
    SephcoccoPharmacyProduct
  end

  def product_category_association_name
    :sephcocco_pharmacy_product_categories
  end

  def product_category_params
    params.require(:product_category).permit(:name, :description, :slug)
  end
end
