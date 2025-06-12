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
    if current_user.sephcocco_user_role.name == "admin"
      Lounge::Admin::SephcoccoLoungeProductSerializer
    else
      Lounge::User::SephcoccoLoungeProductSerializer
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

  def product_params
    params.require(:product).permit(
      :name,
      :short_description,
      :long_description,
      :image_url,
      :amount_in_stock,
      :price,
      :visible,
      category_ids: [],
      other_images: [],
    )
  end
end
