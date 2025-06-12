class Pharmacy::SephcoccoPharmacyProduct < ApplicationRecord
  include ProductModelHelper

  def self.category_association_name
    :sephcocco_pharmacy_product_categories
  end

  def self.join_table_name
    :pharmacy_product_categories_pharmacy_products
  end

  def self.category_product_foreign_key
    :pharmacy_product_id
  end

  def self.category_association_foreign_key_name
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

  # Add attribute accessor for category_ids
  attr_accessor :category_ids

  # Add this line to handle category_ids
  accepts_nested_attributes_for :sephcocco_pharmacy_product_categories, allow_destroy: true

  # Add callback to handle category_ids after save
  after_save :assign_categories

  private

  def assign_categories
    return unless category_ids.present?
    self.sephcocco_pharmacy_product_categories = Pharmacy::SephcoccoPharmacyProductCategory.where(id: category_ids)
  end
end
