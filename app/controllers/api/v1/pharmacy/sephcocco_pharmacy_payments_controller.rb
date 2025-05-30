class Api::V1::Pharmacy::SephcoccoPharmacyPaymentsController < ApplicationController
  include Api::V1::Concerns::PaymentsControllerHelper

  private

  def payment_class
    SephcoccoPharmacyPayment
  end

  def payment_association
    :sephcocco_pharmacy_payments
  end

  def payment_params
    params.require(:sephcocco_pharmacy_payment).permit(
      :sephcocco_user_id,
      :order_id,
      :amount,
      :payment_method,
      :status,
      :transaction_id
    )
  end
end
