class Lounge::SephcoccoLoungeStockManagement < ApplicationRecord
  belongs_to :sephcocco_lounge_product, class_name: "Lounge::SephcoccoLoungeProduct"
end
