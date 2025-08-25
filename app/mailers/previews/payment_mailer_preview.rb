class PaymentMailerPreview < ActionMailer::Preview
  def payment_confirmed_email
    # Get a sample payment for preview
    payment = Pharmacy::SephcoccoPharmacyPayment.first || 
              Restaurant::SephcoccoRestaurantPayment.first || 
              Lounge::SephcoccoLoungePayment.first
    
    if payment
      PaymentMailer.with(payment: payment).payment_confirmed_email
    else
      # Create a mock payment for preview
      mock_payment = OpenStruct.new(
        transaction_id: "TXN_123456789",
        amount: 15000.00,
        payment_method: "card",
        status: "payment confirmed",
        created_at: Time.current,
        updated_at: Time.current,
        sephcocco_user: OpenStruct.new(name: "John Doe", email: "john@example.com"),
        orders: ["order-uuid-1", "order-uuid-2"]
      )
      
      PaymentMailer.with(payment: mock_payment).payment_confirmed_email
    end
  end

  def payment_failed_email
    # Get a sample payment for preview
    payment = Pharmacy::SephcoccoPharmacyPayment.first || 
              Restaurant::SephcoccoRestaurantPayment.first || 
              Lounge::SephcoccoLoungePayment.first
    
    if payment
      PaymentMailer.with(payment: payment, reason: "Insufficient funds").payment_failed_email
    else
      # Create a mock payment for preview
      mock_payment = OpenStruct.new(
        transaction_id: "TXN_123456789",
        amount: 15000.00,
        payment_method: "card",
        status: "failed",
        created_at: Time.current,
        updated_at: Time.current,
        sephcocco_user: OpenStruct.new(name: "John Doe", email: "john@example.com")
      )
      
      PaymentMailer.with(payment: mock_payment, reason: "Insufficient funds").payment_failed_email
    end
  end

  def payment_declined_email
    # Get a sample payment for preview
    payment = Pharmacy::SephcoccoPharmacyPayment.first || 
              Restaurant::SephcoccoRestaurantPayment.first || 
              Lounge::SephcoccoLoungePayment.first
    
    if payment
      PaymentMailer.with(payment: payment, reason: "Card declined by bank").payment_declined_email
    else
      # Create a mock payment for preview
      mock_payment = OpenStruct.new(
        transaction_id: "TXN_123456789",
        amount: 15000.00,
        payment_method: "card",
        status: "declined",
        created_at: Time.current,
        updated_at: Time.current,
        sephcocco_user: OpenStruct.new(name: "John Doe", email: "john@example.com")
      )
      
      PaymentMailer.with(payment: mock_payment, reason: "Card declined by bank").payment_declined_email
    end
  end

  def payment_refund_email
    # Get a sample payment for preview
    payment = Pharmacy::SephcoccoPharmacyPayment.first || 
              Restaurant::SephcoccoRestaurantPayment.first || 
              Lounge::SephcoccoLoungePayment.first
    
    if payment
      PaymentMailer.with(
        payment: payment, 
        refund_amount: 15000.00,
        refund_reason: "Order cancelled by customer"
      ).payment_refund_email
    else
      # Create a mock payment for preview
      mock_payment = OpenStruct.new(
        transaction_id: "TXN_123456789",
        amount: 15000.00,
        payment_method: "card",
        status: "refunded",
        created_at: Time.current,
        updated_at: Time.current,
        sephcocco_user: OpenStruct.new(name: "John Doe", email: "john@example.com")
      )
      
      PaymentMailer.with(
        payment: mock_payment, 
        refund_amount: 15000.00,
        refund_reason: "Order cancelled by customer"
      ).payment_refund_email
    end
  end
end
