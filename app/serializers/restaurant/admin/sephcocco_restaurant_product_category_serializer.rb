class Restaurant::Admin::SephcoccoRestaurantProductCategorySerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :slug,
              :description,
              :created_at,
              :updated_at
end
