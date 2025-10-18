class Restaurant::SephcoccoRestaurantVendor < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  has_many :sephcocco_restaurant_stock_managements, class_name: "Restaurant::SephcoccoRestaurantStockManagement", foreign_key: :sephcocco_restaurant_vendor_id, dependent: :nullify
end
