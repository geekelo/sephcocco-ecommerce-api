class Restaurant::SephcoccoRestaurantOrder < ApplicationRecord
  include OrderModelHelper

  belongs_to :sephcocco_restuarant_product
  belongs_to :sephcocco_user

  # Alias to standardize the method used in the concern
  def product
    sephcocco_restaurant_product
  end
end
