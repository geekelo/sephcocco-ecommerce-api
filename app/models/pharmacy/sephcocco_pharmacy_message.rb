class Pharmacy::SephcoccoPharmacyMessage < ApplicationRecord
  belongs_to :sephcocco_user, optional: true
  belongs_to :sephcocco_pharmacy_product, optional: true
end
