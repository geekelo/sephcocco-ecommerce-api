class SephcoccoUserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :address, :payment_ref, :phone_number, :whatsapp_number, :role, :outlets, :suspended, :last_login_at, :created_at, :updated_at, :total_orders, :total_shippings, :subroles, :email_confirmed

  def role
    object&.sephcocco_user_role&.name
  end

  def subroles
    object&.sephcocco_user_subroles&.map do |subrole|
      subrole.name
    end || []
  end

  def outlets
    object&.sephcocco_outlets&.map do |outlet|
      outlet.name
    end || []
  end

  def total_orders
    pharmacy_orders = Pharmacy::SephcoccoPharmacyOrder.where(sephcocco_user_id: object.id, status: "paid")
    restaurant_orders = Restaurant::SephcoccoRestaurantOrder.where(sephcocco_user_id: object.id, status: "paid")
    lounge_orders = Lounge::SephcoccoLoungeOrder.where(sephcocco_user_id: object.id, status: "paid")
    total_orders = pharmacy_orders.count + restaurant_orders.count + lounge_orders.count
    total_orders
  end

  def total_shippings
    if object.sephcocco_user_role.name == "rider"
      pharmacy_shippings = Pharmacy::SephcoccoPharmacyShipping.where(rider_id: object.id, status: "delivered")
      restaurant_shippings = Restaurant::SephcoccoRestaurantShipping.where(rider_id: object.id, status: "delivered")
      lounge_shippings = Lounge::SephcoccoLoungeShipping.where(rider_id: object.id, status: "delivered")
      total_shippings = pharmacy_shippings.count + restaurant_shippings.count + lounge_shippings.count
      total_shippings
    else
      total_shippings = "not a rider"
    end
  end
end
