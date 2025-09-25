class Restaurant::Admin::SephcoccoRestaurantProductCategorySerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :slug,
              :description,
              :created_at,
              :updated_at,
              :total_products

  def total_products
    object&.sephcocco_restaurant_products&.count || 0
  end
end
