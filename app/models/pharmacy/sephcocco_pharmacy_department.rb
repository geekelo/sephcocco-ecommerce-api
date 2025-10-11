class Pharmacy::SephcoccoPharmacyDepartment < ApplicationRecord
  has_many :sephcocco_pharmacy_products, 
           class_name: "Pharmacy::SephcoccoPharmacyProduct", 
           foreign_key: :sephcocco_pharmacy_department_id, 
           dependent: :destroy
  
  has_many :sephcocco_pharmacy_orders, 
           class_name: "Pharmacy::SephcoccoPharmacyOrder", 
           foreign_key: :sephcocco_pharmacy_department_id,
           dependent: :destroy

  has_many :sephcocco_pharmacy_stock_managements, 
           class_name: "Pharmacy::SephcoccoPharmacyStockManagement", 
           foreign_key: :sephcocco_pharmacy_department_id,
           dependent: :destroy
           
  has_many :sephcocco_pharmacy_payments, 
           class_name: "Pharmacy::SephcoccoPharmacyPayment", 
           foreign_key: :sephcocco_pharmacy_department_id,
           dependent: :destroy
           
  has_many :sephcocco_pharmacy_shippings, 
           class_name: "Pharmacy::SephcoccoPharmacyShipping", 
           foreign_key: :sephcocco_pharmacy_department_id,
           dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :active, inclusion: { in: [true, false] }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
end
