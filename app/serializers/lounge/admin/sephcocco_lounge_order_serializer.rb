class Lounge::Admin::SephcoccoLoungeOrderSerializer < ActiveModel::Serializer
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

  def payment_details
    object&.sephcocco_lounge_payment
  end

  def shipping_details
    object&.sephcocco_lounge_shipping
  end

  def product
    object&.sephcocco_lounge_product
  end

  def customer
    object&.sephcocco_user
  end

  belongs_to :sephcocco_lounge_payment, serializer: Lounge::Admin::SephcoccoLoungePaymentSerializer
end
