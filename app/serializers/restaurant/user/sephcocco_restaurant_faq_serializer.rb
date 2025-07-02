class Restaurant::User::SephcoccoRestaurantFaqSerializer < ActiveModel::Serializer
  attributes :id, :title, :answer, :position, :created_at

  belongs_to :sephcocco_restaurant_faq_category, serializer: Restaurant::User::SephcoccoRestaurantFaqCategorySerializer
end 