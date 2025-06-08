class Api::V1::Restaurant::SephcoccoRestaurantMessage < ApplicationRecord
  belongs_to :sephcocco_user, optional: true
  belongs_to :sephcocco_restaurant_product
end
