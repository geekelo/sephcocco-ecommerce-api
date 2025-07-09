class Api::V1::Lounge::SephcoccoLoungePaymentsController < ApplicationController
  include Api::V1::Concerns::PaymentsControllerHelper

  private

  def payment_class
    SephcoccoLoungePayment
  end

  def payment_association
    :sephcocco_lounge_payments
  end

  def order_class
    SephcoccoLoungeOrder
  end

  def outlet
    "Lounge"
  end
  
  def payment_serializer
    if current_user.sephcocco_user_role.name == "admin"
      Lounge::Admin::SephcoccoLoungePaymentSerializer
    else
      Lounge::User::SephcoccoLoungePaymentSerializer
    end
  end

  def payment_params
    params.require(:sephcocco_lounge_payment).permit(
      :sephcocco_user_id,
      :amount,
      :payment_method,
      :status,
      :transaction_id,
      orders_ids: []
    )
  end
end
