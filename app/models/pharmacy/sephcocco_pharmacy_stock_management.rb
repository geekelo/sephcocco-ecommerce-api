class Pharmacy::SephcoccoPharmacyStockManagement < ApplicationRecord
  belongs_to :sephcocco_pharmacy_product, class_name: "Pharmacy::SephcoccoPharmacyProduct"
  belongs_to :sephcocco_pharmacy_department, class_name: "Pharmacy::SephcoccoPharmacyDepartment", optional: true
  belongs_to :sephcocco_pharmacy_vendor, class_name: "Pharmacy::SephcoccoPharmacyVendor", optional: true
end
