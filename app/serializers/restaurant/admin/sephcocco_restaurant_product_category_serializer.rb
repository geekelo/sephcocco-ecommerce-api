class Restaurant::Admin::SephcoccoRestaurantProductCategorySerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :slug,
              :products,
              :description,
              :created_at,
              :updated_at


  def products
    object.sephcocco_restaurant_products.map do |product|
      Restaurant::Admin::SephcoccoRestaurantProductSerializer.new(product).as_json
    end
  end
end
