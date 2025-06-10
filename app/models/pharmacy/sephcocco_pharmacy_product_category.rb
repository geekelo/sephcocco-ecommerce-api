class Pharmacy::SephcoccoPharmacyProductCategory < ApplicationRecord
  include ProductCategoryModelHelper

  def self.product_association_name
    :sephcocco_pharmacy_products
  end

  def self.join_table_name
    "pharmacy_product_categories_pharmacy_products"
  end

  def self.category_foreign_key
    :sephcocco_pharmacy_product_category_id
  end

  def self.product_foreign_key
    :sephcocco_pharmacy_product_id
  end

  # Setup associations AFTER defining the required class methods
  setup_product_category_association
end
