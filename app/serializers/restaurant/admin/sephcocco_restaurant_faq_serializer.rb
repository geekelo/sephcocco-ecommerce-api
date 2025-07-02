class Restaurant::Admin::SephcoccoRestaurantFaqSerializer < ActiveModel::Serializer
  attributes :id, :title, :answer, :visibility, :position, :update_history, :created_at, :updated_at

  belongs_to :sephcocco_restaurant_faq_category, serializer: Restaurant::Admin::SephcoccoRestaurantFaqCategorySerializer
end 