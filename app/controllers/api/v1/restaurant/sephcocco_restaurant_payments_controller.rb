class Api::V1::Restaurant::SephcoccoRestaurantPaymentsController < ApplicationController
  include Api::V1::Concerns::PaymentsControllerHelper

  private

  def payment_class
    SephcoccoRestaurantPayment
  end

  def payment_association
    :sephcocco_restaurant_payments
  end

  def order_class
    SephcoccoRestaurantOrder
  end

  def payment_params
    params.require(:sephcocco_restaurant_payment).permit(
      :sephcocco_user_id,
      :orders_ids,
      :amount,
      :payment_method,
      :status,
      :transaction_id
    )
  end
end
