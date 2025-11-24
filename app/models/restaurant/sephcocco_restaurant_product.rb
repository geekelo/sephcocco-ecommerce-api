class Restaurant::SephcoccoRestaurantProduct < ApplicationRecord
  include ProductModelHelper

  def self.category_association_name
    :sephcocco_restaurant_product_categories
  end

  def self.join_table_name
    :restaurant_product_categories_restaurant_products
  end

  def self.category_product_foreign_key
    :restaurant_product_id
  end

  def self.category_association_foreign_key_name
    :restaurant_product_category_id
  end

  def self.product_foreign_key
    :sephcocco_restaurant_product_id
  end

  def self.category_foreign_key
    :sephcocco_restaurant_product_category_id
  end

  def self.product_like_class
    Restaurant::SephcoccoRestaurantProductLike
  end

  def self.order_class
    Restaurant::SephcoccoRestaurantOrder
  end

  def self.likes_association_name
    :sephcocco_restaurant_product_likes
  end

  def self.order_association_name
    :restaurant_orders
  end

  def self.stock_management_class
    Restaurant::SephcoccoRestaurantStockManagement
  end

  # 🔧 Call the association setup after all class methods are defined
  setup_product_associations
  
  # Add stock management association
  has_many :sephcocco_restaurant_stock_managements, class_name: "Restaurant::SephcoccoRestaurantStockManagement", foreign_key: :sephcocco_restaurant_product_id, dependent: :destroy
  
  # Add department association
  belongs_to :sephcocco_restaurant_department, class_name: "Restaurant::SephcoccoRestaurantDepartment", optional: true
end
