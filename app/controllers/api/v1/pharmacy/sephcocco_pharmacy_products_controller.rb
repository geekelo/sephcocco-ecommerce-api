# app/controllers/api/v1/pharmacy/sephcocco_pharmacy_products_controller.rb
class Api::V1::Pharmacy::SephcoccoPharmacyProductsController < ApplicationController
  include Api::V1::Concerns::ProductsControllerHelper

  private

  def product_class
    Pharmacy::SephcoccoPharmacyProduct
  end

  def category_class
    Pharmacy::SephcoccoPharmacyProductCategory
  end

  def like_class
    Pharmacy::SephcoccoPharmacyProductLike
  end

  def unnested_product_serializer
    Pharmacy::SephcoccoPharmacyProductSerializer
  end

  def product_serializer
    if current_user&.sephcocco_user_role&.name == "admin"
      Pharmacy::Admin::SephcoccoPharmacyProductSerializer
    elsif current_user&.sephcocco_user_role&.name == "user"
      Pharmacy::User::SephcoccoPharmacyProductSerializer
    else
      Pharmacy::SephcoccoPharmacyProductSerializer
    end
  end

  def product_key
    :sephcocco_pharmacy_product_id
  end

  def admin_notification_class
    Pharmacy::SephcoccoPharmacyAdminNotification
  end

  def user_key
    :sephcocco_user_id
  end

  def category_association_name
    :sephcocco_pharmacy_product_categories
  end

  def outlet
    "pharmacy"
  end

  def admin_notification_class
    Pharmacy::SephcoccoPharmacyAdminNotification
  end

  def product_params
    params.require(:product).permit(
      :name,
      :short_description,
      :long_description,
      :main_image_url,
      :amount_in_stock,
      :discount_price,
      :price,
      :visible,
      :barcode,
      :sephcocco_pharmacy_department_id,
      category_ids: [],
      other_image_urls: []
    )
  end
end
