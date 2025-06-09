class Restaurant::SephcoccoRestaurantProductCategorySerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :description,
              :created_at,
              :updated_at
end
