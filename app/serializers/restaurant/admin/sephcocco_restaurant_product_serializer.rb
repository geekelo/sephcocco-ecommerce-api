class Restaurant::Admin::SephcoccoRestaurantProductSerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :image_url,
              :short_description,
              :long_description,
              :other_images,
              :amount_in_stock,
              :likes,
              :visible,
              :price,
              :categories,
              :created_at,
              :updated_at,

  def categories
    object.sephcocco_restaurant_product_categories.map do |category|
      Restaurant::Admin::SephcoccoRestaurantProductCategorySerializer.new(category)
    end
  end
end
