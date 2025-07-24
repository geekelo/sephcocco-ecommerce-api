class Pharmacy::SephcoccoPharmacyMessage < ApplicationRecord
  belongs_to :sephcocco_user, foreign_key: 'sephcocco_users_id', optional: true
  belongs_to :sephcocco_pharmacy_product
end
