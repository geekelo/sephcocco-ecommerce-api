class SephcoccoPharmacyOrder < ApplicationRecord
  include OrderCallbacks

  belongs_to :sephcocco_pharmacy_product
  belongs_to :sephcocco_user

  # Alias to standardize the method used in the concern
  def product
    sephcocco_pharmacy_product
  end
end
