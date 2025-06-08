class Api::V1::Pharmacy::SephcoccoPharmacyProductLike < ApplicationRecord
  include Api::V1::ProductLikeModelHelper

  def self.user_class_name
    "SephcoccoUser"
  end

  def self.product_class_name
    "SephcoccoPharmacyProduct"
  end

  def self.user_foreign_key
    :sephcocco_user_id
  end

  def self.product_foreign_key
    :sephcocco_pharmacy_product_id
  end

  # Setup associations *after* class methods are defined
  setup_product_like_associations
end
