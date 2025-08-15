
class Pharmacy::SephcoccoPharmacyOrder < ApplicationRecord
  include OrderModelHelper

  belongs_to :sephcocco_pharmacy_product
  belongs_to :sephcocco_user
  belongs_to :sephcocco_pharmacy_payment, optional: true
  has_one :sephcocco_pharmacy_shipping, class_name: "Pharmacy::SephcoccoPharmacyShipping", dependent: :destroy

  # Alias to standardize the method used in the concern
  def product
    sephcocco_pharmacy_product
  end
end
