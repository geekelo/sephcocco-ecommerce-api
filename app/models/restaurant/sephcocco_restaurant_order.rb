class Restaurant::SephcoccoRestaurantOrder < ApplicationRecord
  include OrderModelHelper

  belongs_to :sephcocco_restaurant_product
  belongs_to :sephcocco_user
  belongs_to :sephcocco_restaurant_payment, optional: true
  belongs_to :sephcocco_restaurant_department, class_name: "Restaurant::SephcoccoRestaurantDepartment", optional: true
  has_one :sephcocco_restaurant_shipping, class_name: "Restaurant::SephcoccoRestaurantShipping", dependent: :destroy
  
  # Alias to standardize the method used in the concern
  def product
    sephcocco_restaurant_product
  end
end
