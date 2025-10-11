class Restaurant::SephcoccoRestaurantStockManagement < ApplicationRecord
  belongs_to :sephcocco_restaurant_product, class_name: "Restaurant::SephcoccoRestaurantProduct"
  belongs_to :sephcocco_restaurant_department, class_name: "Restaurant::SephcoccoRestaurantDepartment", optional: true
end
