class Pharmacy::SephcoccoPharmacyProduct < ApplicationRecord
  include ProductModelHelper

  def self.category_association_name
    :sephcocco_pharmacy_product_categories
  end

  def self.join_table_name
    :pharmacy_product_categories_pharmacy_products
  end

  def self.category_product_foreign_key
    :pharmacy_product_category_id
  end

  def self.product_foreign_key
    :sephcocco_pharmacy_product_id
  end

  def self.category_foreign_key
    :sephcocco_pharmacy_product_category_id
  end

  def self.product_like_class
    Pharmacy::SephcoccoPharmacyProductLike
  end

  def self.order_class
    Pharmacy::SephcoccoPharmacyOrder
  end

  def self.likes_association_name
    :pharmacy_product_likes
  end

  def self.order_association_name
    :pharmacy_orders
  end

  # 🔧 Call the association setup after all class methods are defined
  setup_product_associations
end
