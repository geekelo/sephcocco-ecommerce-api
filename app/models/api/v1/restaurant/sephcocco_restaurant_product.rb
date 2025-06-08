class Api::V1::Restaurant::SephcoccoRestaurantProduct < ApplicationRecord
  include Api::V1::ProductModelHelper

  def self.category_association_name
    :restaurant_product_categories
  end

  def self.join_table_name
    :sephcocco_restaurant_product_categories_products
  end

  def self.product_foreign_key
    :sephcocco_restaurant_product_id
  end

  def self.category_foreign_key
    :sephcocco_restaurant_product_category_id
  end

  def self.product_like_class
    Api::V1::Restaurant::SephcoccoRestaurantProductLike
  end

  def self.order_class
    Api::V1::Restaurant::SephcoccoRestaurantOrder
  end

  def self.likes_association_name
    :restaurant_product_likes
  end

  def self.order_association_name
    :restaurant_orders
  end

  # 🔧 Call the association setup after all class methods are defined
  setup_product_associations
end
