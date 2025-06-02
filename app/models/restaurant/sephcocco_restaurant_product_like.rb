class Restaurant::SephcoccoRestaurantProductLike < ApplicationRecord
  include ProductLikeModelHelper

  def self.user_class_name
    "SephcoccoUser"
  end

  def self.product_class_name
    "SephcoccoRestaurantProduct"
  end

  def self.user_foreign_key
    :sephcocco_user_id
  end

  def self.product_foreign_key
    :sephcocco_restaurant_product_id
  end

  # Setup associations *after* class methods are defined
  setup_product_like_associations
end
