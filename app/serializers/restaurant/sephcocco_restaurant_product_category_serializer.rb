class Restaurant::SephcoccoRestaurantProductCategorySerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :description,
              :created_at,
              :updated_at,
              :total_products,

  def total_products
    object&.sephcocco_restaurant_products&.count || 0
  end
end
