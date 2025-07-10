class Api::V1::Restaurant::SephcoccoRestaurantPaymentsController < ApplicationController
  include Api::V1::Concerns::PaymentsControllerHelper

  private

  def payment_class
    Restaurant::SephcoccoRestaurantPayment
  end

  def payment_association
    :sephcocco_restaurant_payments
  end

  def order_class
    Restaurant::SephcoccoRestaurantOrder
  end

  def outlet
    'restaurant'
  end

  def payment_serializer
    if current_user.sephcocco_user_role.name == "admin"
      Restaurant::Admin::SephcoccoRestaurantPaymentSerializer
    else
      Restaurant::User::SephcoccoRestaurantPaymentSerializer
    end
  end

  def payment_params
    params.require(:sephcocco_restaurant_payment).permit(
      :sephcocco_user_id,
      :amount,
      :payment_method,
      :status,
      :transaction_id,
      orders_ids: []
    )
  end
end
