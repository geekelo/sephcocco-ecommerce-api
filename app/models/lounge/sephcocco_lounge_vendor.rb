class Lounge::SephcoccoLoungeVendor < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  
  has_many :sephcocco_lounge_stock_managements, class_name: "Lounge::SephcoccoLoungeStockManagement", foreign_key: :sephcocco_lounge_vendor_id, dependent: :nullify
end
