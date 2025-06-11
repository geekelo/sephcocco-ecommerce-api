class Restaurant::SephcoccoRestaurantProductCategory < ApplicationRecord
  include ProductCategoryModelHelper

  def self.product_association_name
    :sephcocco_restaurant_products
  end

  def self.join_table_name
    :restaurant_product_categories_restaurant_products
  end

  def self.category_foreign_key
    :restaurant_product_category_id
  end

  def self.product_foreign_key
    :restaurant_product_categories_id
  end

  # Setup associations AFTER defining the required class methods
  setup_product_category_association
end
