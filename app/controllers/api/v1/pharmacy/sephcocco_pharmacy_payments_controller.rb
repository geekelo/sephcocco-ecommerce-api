class Api::V1::Pharmacy::SephcoccoPharmacyPaymentsController < ApplicationController
  include Api::V1::Concerns::PaymentsControllerHelper

  private

  def payment_class
    SephcoccoPharmacyPayment
  end

  def payment_association
    :sephcocco_pharmacy_payments
  end

  def order_class
    SephcoccoPharmacyOrder
  end

  def outlet
    "Pharmacy"
  end

  def payment_serializer
    if current_user.sephcocco_user_role.name == "admin"
      Pharmacy::Admin::SephcoccoPharmacyPaymentSerializer
    else
      Pharmacy::User::SephcoccoPharmacyPaymentSerializer
    end
  end

  def payment_params
    params.require(:sephcocco_pharmacy_payment).permit(
      :sephcocco_user_id,
      :amount,
      :payment_method,
      :status,
      :transaction_id,
      orders_ids: []
    )
  end
end
