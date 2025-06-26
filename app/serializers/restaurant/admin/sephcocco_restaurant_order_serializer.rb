class Restaurant::Admin::SephcoccoRestaurantOrderSerializer < ActiveModel::Serializer
  attributes  :id,
              :sephcocco_user_id,
              :status,
              :stages,
              :order_number,
              :quantity,
              :unit_price,
              :total_cost,
              :total_price,
              :created_at,
              :updated_at,
              :product,
              :customer

  def product
    prod = object.sephcocco_restaurant_product
    return nil unless prod
    {
      id: prod.id,
      name: prod.name,
      main_image_url: prod.main_image_url,
    }
  end

  def customer
    object&.sephcocco_user
  end
end
