class Api::V1::Lounge::SephcoccoLoungePaymentsController < ApplicationController
  include Api::V1::Concerns::PaymentsControllerHelper

  private

  def payment_class
    SephcoccoLoungePayment
  end

  def payment_association
    :sephcocco_lounge_payments
  end

  def payment_params
    params.require(:sephcocco_lounge_payment).permit(
      :sephcocco_user_id,
      :order_id,
      :amount,
      :payment_method,
      :status,
      :transaction_id
    )
  end
end
