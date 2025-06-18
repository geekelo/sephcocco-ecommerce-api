class Lounge::SephcoccoLoungeProductSerializer < ActiveModel::Serializer
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
              :visible,
              :categories,
              :created_at,
              :updated_at,

  def categories
    return [] unless object.sephcocco_lounge_product_categories.any?
    object.sephcocco_lounge_product_categories.map do |category|
      {
        id: category.id, 
        name: category.name,
        description: category.description,
        slug: category.slug,
      }
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
    user = scope
    return false unless user
    object&.sephcocco_lounge_product_likes&.exists?(sephcocco_user_id: user.id)
  end
end
