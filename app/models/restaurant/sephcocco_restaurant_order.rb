class Restaurant::SephcoccoRestaurantOrder < ApplicationRecord
  include OrderModelHelper

  belongs_to :sephcocco_restaurant_product
  belongs_to :sephcocco_user
  belongs_to :sephcocco_restaurant_payment, optional: true
  
  # Alias to standardize the method used in the concern
  def product
    sephcocco_restaurant_product
  end
end
