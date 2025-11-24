class Lounge::SephcoccoLoungeDepartment < ApplicationRecord
  has_many :sephcocco_lounge_products, 
           class_name: "Lounge::SephcoccoLoungeProduct", 
           foreign_key: :sephcocco_lounge_department_id, 
           dependent: :destroy
  
  has_many :sephcocco_lounge_orders, 
           class_name: "Lounge::SephcoccoLoungeOrder", 
           foreign_key: :sephcocco_lounge_department_id,
           dependent: :destroy

  has_many :sephcocco_lounge_stock_managements, 
           class_name: "Lounge::SephcoccoLoungeStockManagement", 
           foreign_key: :sephcocco_lounge_department_id,
           dependent: :destroy
           
  has_many :sephcocco_lounge_payments, 
           class_name: "Lounge::SephcoccoLoungePayment", 
           foreign_key: :sephcocco_lounge_department_id,
           dependent: :destroy
           
  has_many :sephcocco_lounge_shippings, 
           class_name: "Lounge::SephcoccoLoungeShipping", 
           foreign_key: :sephcocco_lounge_department_id,
           dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :active, inclusion: { in: [true, false] }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
end
