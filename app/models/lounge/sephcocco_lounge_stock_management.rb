class Lounge::SephcoccoLoungeStockManagement < ApplicationRecord
  belongs_to :sephcocco_lounge_product, class_name: "Lounge::SephcoccoLoungeProduct"
  belongs_to :sephcocco_lounge_department, class_name: "Lounge::SephcoccoLoungeDepartment", optional: true
  belongs_to :sephcocco_lounge_vendor, class_name: "Lounge::SephcoccoLoungeVendor", optional: true
end
