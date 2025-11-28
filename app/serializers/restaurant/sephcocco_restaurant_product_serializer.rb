class Restaurant::SephcoccoRestaurantProductSerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :short_description,
              :long_description,
              :amount_in_stock,
              :out_of_stock_status,
              :likes,
              :liked_by_user,
              :price,
              :discount_price,
              :main_image_url,
              :other_image_urls,
              :visible,
              :barcode,
              :categories,
              :department,          
              :created_at,
              :updated_at

  def categories
    return [] unless object.sephcocco_restaurant_product_categories.any?
    object.sephcocco_restaurant_product_categories.map do |category|
      {
        id: category.id, 
        name: category.name,
        description: category.description,
        slug: category.slug
      }
    end
  end

  def out_of_stock_status
    object.amount_in_stock <= 0
  end

  def liked_by_user
    user = scope
    return false unless user
    object&.sephcocco_restaurant_product_likes&.exists?(sephcocco_user_id: user.id)
  end

  def department
    return nil unless object.sephcocco_restaurant_department.present?
    {
      id: object.sephcocco_restaurant_department.id,
      name: object.sephcocco_restaurant_department.name
    }
  end
end
