class Pharmacy::SephcoccoPharmacyStockManagement < ApplicationRecord
  belongs_to :sephcocco_pharmacy_product, class_name: "Pharmacy::SephcoccoPharmacyProduct"
end
