class Pharmacy::Admin::SephcoccoPharmacyOrderSerializer < ActiveModel::Serializer
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
              :payment_details,
              :address,
              :phone_number,
              :additional_notes,
              :shipping_details,
              :product_details

  def product
    object&.sephcocco_pharmacy_product
  end

  def product_details
    prod = object.sephcocco_pharmacy_product
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

  def payment_details
    object&.sephcocco_pharmacy_payment
  end

  def shipping_details
    object&.sephcocco_pharmacy_shipping
  end

  belongs_to :sephcocco_pharmacy_payment, serializer: Pharmacy::Admin::SephcoccoPharmacyPaymentSerializer
end
