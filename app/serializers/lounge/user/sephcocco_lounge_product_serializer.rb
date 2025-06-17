class Lounge::User::SephcoccoLoungeProductSerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :main_image_url,
              :short_description,
              :long_description,
              :other_image_urls,
              :amount_in_stock,
              :out_of_stock_status,
              :likes,
              :liked_by_user,
              :discount_price,
              :price,
              :categories,
              :created_at,
              :updated_at

  def categories
    object.sephcocco_lounge_product_categories.map do |category|
      Lounge::User::SephcoccoLoungeProductCategorySerializer.new(category)
    end
  end

  def out_of_stock_status
    if object.amount_in_stock > 0
      false
    else
      true
    end
  end

  def liked_by_user
    return false unless current_user
    object&.sephcocco_pharmacy_product_likes&.exists?(sephcocco_user_id: current_user.id)
  end
end
