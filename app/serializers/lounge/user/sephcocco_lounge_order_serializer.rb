class Lounge::User::SephcoccoLoungeOrderSerializer < ActiveModel::Serializer
  attributes  :id,
              :status,
              :order_number,
              :quantity,
              :unit_price,
              :total_cost,
              :total_price,
              :created_at,
              :updated_at,
              :product,
              :address,
              :phone_number,
              :additional_notes,
              :payment_details,
              :shipping_details

  def payment_details
    object&.sephcocco_lounge_payment
  end

  def shipping_details
    object&.sephcocco_lounge_shipping
  end

  def product
    prod = object.sephcocco_lounge_product
    return nil unless prod
    {
      id: prod.id,
      name: prod.name,
      main_image_url: prod.main_image_url,
    }
  end
end
