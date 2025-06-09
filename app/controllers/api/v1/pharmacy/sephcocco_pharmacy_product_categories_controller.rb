# app/controllers/api/v1/pharmacy/sephcocco_pharmacy_product_categories_controller.rb
class Api::V1::Pharmacy::SephcoccoPharmacyProductCategoriesController < ApplicationController
  include Api::V1::Concerns::ProductCategoriesControllerHelper

  private

  def category_class
    Pharmacy::SephcoccoPharmacyProductCategory
  end

  def product_class
    Pharmacy::SephcoccoPharmacyProduct
  end

  def product_category_unnested_serializer
    Pharmacy::SephcoccoPharmacyProductCategorySerializer
  end
  
  def product_category_serializer
    if current_user.sephcocco_user_role.name == "admin"
      Pharmacy::Admin::SephcoccoPharmacyProductCategorySerializer
    else
      Pharmacy::User::SephcoccoPharmacyProductCategorySerializer
    end
  end

  def product_category_association_name
    :sephcocco_pharmacy_product_categories
  end

  def product_category_params
    params.require(:product_category).permit(:name, :description, :slug)
  end
end
