class Restaurant::SephcoccoRestaurantDepartment < ApplicationRecord
  has_many :sephcocco_restaurant_products, 
           class_name: "Restaurant::SephcoccoRestaurantProduct", 
           foreign_key: :sephcocco_restaurant_department_id,
           dependent: :destroy

  has_many :sephcocco_restaurant_orders, 
           class_name: "Restaurant::SephcoccoRestaurantOrder", 
           foreign_key: :sephcocco_restaurant_department_id,
           dependent: :destroy

  has_many :sephcocco_restaurant_stock_managements, 
           class_name: "Restaurant::SephcoccoRestaurantStockManagement", 
           foreign_key: :sephcocco_restaurant_department_id,
           dependent: :destroy
           
  has_many :sephcocco_restaurant_payments, 
           class_name: "Restaurant::SephcoccoRestaurantPayment", 
           foreign_key: :sephcocco_restaurant_department_id,
           dependent: :destroy
           
  has_many :sephcocco_restaurant_shippings, 
           class_name: "Restaurant::SephcoccoRestaurantShipping", 
           foreign_key: :sephcocco_restaurant_department_id,
           dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :active, inclusion: { in: [true, false] }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
end
