class Restaurant::Admin::SephcoccoRestaurantOrderSerializer < ActiveModel::Serializer
  attributes  :id,
              :sephcocco_user_id,
              :status,
              :stages,
              :current_stage,
              :order_number,
              :quantity,
              :unit_price,
              :total_cost,
              :total_price,
              :created_at,
              :updated_at,
              :product,
              :customer,  
              :address,
              :phone_number,
              :additional_notes,
              :shipping_details

  def product
    object&.sephcocco_restaurant_product
  end

  def customer
    object&.sephcocco_user
  end

  def shipping_details
    object&.sephcocco_restaurant_shipping
  end

  belongs_to :sephcocco_restaurant_payment, serializer: Restaurant::Admin::SephcoccoRestaurantPaymentSerializer
end
