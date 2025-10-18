class Pharmacy::SephcoccoPharmacyVendor < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  
  has_many :sephcocco_pharmacy_stock_managements, class_name: "Pharmacy::SephcoccoPharmacyStockManagement", foreign_key: :sephcocco_pharmacy_vendor_id, dependent: :nullify
end
