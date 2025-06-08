class Restaurant::Admin::SephcoccoRestaurantPaymentSerializer < ActiveModel::Serializer
  attributes :id,
               :sephcocco_user_id,
               :amount,
               :status,
               :created_at,
               :updated_at
end
