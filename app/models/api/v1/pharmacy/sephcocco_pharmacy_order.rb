
class Api::V1::Pharmacy::SephcoccoPharmacyOrder < ApplicationRecord
  include Api::V1::OrderModelHelper

  belongs_to :sephcocco_pharmacy_product
  belongs_to :sephcocco_user

  # Alias to standardize the method used in the concern
  def product
    sephcocco_pharmacy_product
  end
end
