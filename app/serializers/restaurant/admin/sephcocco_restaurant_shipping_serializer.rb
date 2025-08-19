class Restaurant::Admin::SephcoccoRestaurantShippingSerializer < ActiveModel::Serializer
  attributes :id,
             :tracking_number,
             :status,
             :rider,
             :datetime_delivered,
             :dispatching,
             :customer,
             :created_at,
             :updated_at

  belongs_to :sephcocco_restaurant_order
  belongs_to :rider, class_name: "SephcoccoUser", optional: true

  def rider
    return nil unless object.rider
    {
      id: object.rider.id,
      name: object.rider.name,
      email: object.rider.email,
      phone: object.rider.phone
    }
  end


  def customer
    object&.sephcocco_lounge_order&.sephcocco_user
  end
end 