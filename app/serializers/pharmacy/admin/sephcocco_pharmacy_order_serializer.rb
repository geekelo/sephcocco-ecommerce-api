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
              :address,
              :phone_number,
              :additional_notes,
              :payment_details,
              :shipping_details

  def product
    object&.sephcocco_pharmacy_product
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
end
