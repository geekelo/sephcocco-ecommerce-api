class PaymentMailer < ApplicationMailer
  def payment_confirmed_email
    @payment = params[:payment]
    @user = @payment.sephcocco_user
    @outlet_type = determine_outlet_type(@payment)
    @orders = get_orders_from_payment(@payment)
    
    mail(
      to: @user.email,
      subject: "Payment Confirmed - #{@payment.transaction_id}"
    )
  end

  def payment_failed_email
    @payment = params[:payment]
    @user = @payment.sephcocco_user
    @outlet_type = determine_outlet_type(@payment)
    @reason = params[:reason] || "Payment processing failed"
    
    mail(
      to: @user.email,
      subject: "Payment Failed - #{@payment.transaction_id}"
    )
  end

  def payment_declined_email
    @payment = params[:payment]
    @user = @payment.sephcocco_user
    @outlet_type = determine_outlet_type(@payment)
    @reason = params[:reason] || "Payment was declined"
    
    mail(
      to: @user.email,
      subject: "Payment Declined - #{@payment.transaction_id}"
    )
  end

  def payment_refund_email
    @payment = params[:payment]
    @user = @payment.sephcocco_user
    @outlet_type = determine_outlet_type(@payment)
    @refund_amount = params[:refund_amount]
    @refund_reason = params[:refund_reason]
    
    mail(
      to: @user.email,
      subject: "Payment Refund - #{@payment.transaction_id}"
    )
  end

  private

  def determine_outlet_type(payment)
    case payment.class.name
    when /Pharmacy/
      'pharmacy'
    when /Restaurant/
      'restaurant'
    when /Lounge/
      'lounge'
    else
      'unknown'
    end
  end

  def get_orders_from_payment(payment)
    # Handle different ways orders might be stored
    if payment.respond_to?(:orders) && payment.orders.present?
      if payment.orders.is_a?(Array)
        # Orders stored as array of IDs
        order_ids = payment.orders
        order_class = determine_order_class(payment)
        order_class.where(id: order_ids) if order_class
      elsif payment.orders.is_a?(ActiveRecord::Relation)
        # Orders stored as association
        payment.orders
      else
        []
      end
    else
      []
    end
  end

  def determine_order_class(payment)
    case payment.class.name
    when /Pharmacy/
      Pharmacy::SephcoccoPharmacyOrder
    when /Restaurant/
      Restaurant::SephcoccoRestaurantOrder
    when /Lounge/
      Lounge::SephcoccoLoungeOrder
    else
      nil
    end
  end
end
