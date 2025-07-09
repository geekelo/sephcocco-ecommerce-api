class Restaurant::User::SephcoccoRestaurantPaymentSerializer < ActiveModel::Serializer
  attributes  :id, :amount, :status, :created_at, :transaction_id, :updated_at, :sephcocco_user_id

  has_many :orders, serializer: Restaurant::User::SephcoccoRestaurantOrderSerializer
end
