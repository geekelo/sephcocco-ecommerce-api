class Restaurant::SephcoccoRestaurantStockManagement < ApplicationRecord
  belongs_to :sephcocco_restaurant_product, class_name: "Restaurant::SephcoccoRestaurantProduct"
end
