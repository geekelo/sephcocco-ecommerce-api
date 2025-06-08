class Api::V1::Restaurant::SephcoccoRestaurantOrder < ApplicationRecord
  include Api::V1::OrderModelHelper

  belongs_to :sephcocco_restaurant_product
  belongs_to :sephcocco_user

  # Alias to standardize the method used in the concern
  def product
    sephcocco_restaurant_product
  end
end
