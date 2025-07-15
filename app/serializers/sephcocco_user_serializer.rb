class SephcoccoUserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :address, :payment_ref, :phone_number, :whatsapp_number, :role, :outlets, :suspended, :last_login_at, :created_at, :updated_at, :total_orders

  def role
    object&.sephcocco_user_role&.name
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

end
