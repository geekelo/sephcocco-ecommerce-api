class Pharmacy::SephcoccoPharmacyVendor < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
