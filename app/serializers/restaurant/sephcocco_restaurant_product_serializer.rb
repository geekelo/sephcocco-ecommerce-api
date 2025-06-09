class Restaurant::SephcoccoRestaurantProductSerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :image_url,
              :short_description,
              :long_description,
              :other_images,
              :amount_in_stock,
              :likes,
              :price,
              :categories,
              :created_at,
              :updated_at

  def categories
    object.sephcocco_restaurant_product_categories.map do |category|
      {
      id: category.id, 
      name: category.name,
      description: category.description,
      slug: category.slug,
    }
    end
  end
end
