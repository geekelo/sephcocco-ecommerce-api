class Restaurant::SephcoccoRestaurantPayment < ApplicationRecord
  include PaymentModelHelper

  belongs_to :sephcocco_user, class_name: "SephcoccoUser", foreign_key: :sephcocco_user_id, optional: true
  belongs_to :sephcocco_restaurant_department, class_name: "Restaurant::SephcoccoRestaurantDepartment", optional: true
  has_many :sephcocco_restaurant_orders, class_name: "Restaurant::SephcoccoRestaurantOrder", foreign_key: :sephcocco_restaurant_payment_id
  
  def associated_order_class
    Restaurant::SephcoccoRestaurantOrder
  end
end
