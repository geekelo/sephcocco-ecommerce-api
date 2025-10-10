class Api::V1::Lounge::SephcoccoLoungePaymentsController < ApplicationController
  include Api::V1::Concerns::PaymentsControllerHelper

  private

  def payment_class
    Lounge::SephcoccoLoungePayment
  end

  def payment_association
    :sephcocco_lounge_payments
  end

  def order_class
    Lounge::SephcoccoLoungeOrder
  end

  def product_class
    Lounge::SephcoccoLoungeProduct
  end

  def outlet
    'lounge'
  end
  
  def payment_serializer
    if current_user.sephcocco_user_role.name == "admin"
      Lounge::Admin::SephcoccoLoungePaymentSerializer
    else
      Lounge::User::SephcoccoLoungePaymentSerializer
    end
  end

  def admin_notification_class
    Lounge::SephcoccoLoungeAdminNotification
  end

  def payment_params
    params.require(:sephcocco_lounge_payment).permit(
      :sephcocco_user_id,
      :amount,
      :payment_method,
      :status,
      :transaction_id,
      :delivery_location_id,
      orders_ids: []
    )
  end
end
