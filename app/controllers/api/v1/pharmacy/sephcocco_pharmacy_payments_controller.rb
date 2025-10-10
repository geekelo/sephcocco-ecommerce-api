class Api::V1::Pharmacy::SephcoccoPharmacyPaymentsController < ApplicationController
  include Api::V1::Concerns::PaymentsControllerHelper

  private

  def payment_class
    Pharmacy::SephcoccoPharmacyPayment
  end

  def payment_association
    :sephcocco_pharmacy_payments
  end

  def order_class
    Pharmacy::SephcoccoPharmacyOrder
  end

  def outlet
    'pharmacy'
  end

  def product_class
    Pharmacy::SephcoccoPharmacyProduct
  end

  def payment_serializer
    if current_user.sephcocco_user_role.name == "admin"
      Pharmacy::Admin::SephcoccoPharmacyPaymentSerializer
    else
      Pharmacy::User::SephcoccoPharmacyPaymentSerializer
    end
  end


  def admin_notification_class
    Pharmacy::SephcoccoPharmacyAdminNotification
  end

  def payment_params
    params.require(:sephcocco_pharmacy_payment).permit(
      :sephcocco_user_id,
      :amount,
      :payment_method,
      :status,
      :transaction_id,
      :reference,
      :delivery_location_id,
      orders_ids: []
    )
  end
end
