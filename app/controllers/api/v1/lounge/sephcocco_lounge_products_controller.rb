# app/controllers/api/v1/sephcocco_lounge_products_controller.rb
class Api::V1::Lounge::SephcoccoLoungeProductsController < ApplicationController
  include Api::V1::Concerns::ProductsControllerHelper

  private

  def product_class
    Lounge::SephcoccoLoungeProduct
  end

  def category_class
    Lounge::SephcoccoLoungeProductCategory
  end

  def like_class
    Lounge::SephcoccoLoungeProductLike
  end

  def product_serializer
    if current_user&.sephcocco_user_role&.name == "admin"
      Lounge::Admin::SephcoccoLoungeProductSerializer
    elsif current_user&.sephcocco_user_role&.name == "user"         
      Lounge::User::SephcoccoLoungeProductSerializer
    else
      Lounge::SephcoccoLoungeProductSerializer
    end
  end

  def unnested_product_serializer
    Lounge::SephcoccoLoungeProductSerializer
  end

  def product_key
    :sephcocco_lounge_product_id
  end

  def user_key
    :sephcocco_user_id
  end

  def category_association_name
    :sephcocco_lounge_product_categories
  end

  def outlet
    "lounge"
  end

  def admin_notification_class
    Lounge::SephcoccoLoungeAdminNotification
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
      :sephcocco_lounge_department_id,
      category_ids: [],
      other_image_urls: []
    )
  end
end
