class OrderMailerPreview < ActionMailer::Preview
  def order_created_email
    # Get a sample order for preview
    order = Pharmacy::SephcoccoPharmacyOrder.first || 
            Restaurant::SephcoccoRestaurantOrder.first || 
            Lounge::SephcoccoLoungeOrder.first
    
    if order
      OrderMailer.with(order: order).order_created_email
    else
      # Create a mock order for preview
      mock_order = OpenStruct.new(
        order_number: "ORD-123456",
        status: "pending",
        total_price: 15000.00,
        created_at: Time.current,
        updated_at: Time.current,
        sephcocco_user: OpenStruct.new(name: "John Doe", email: "john@example.com"),
        sephcocco_pharmacy_products: [
          OpenStruct.new(name: "Paracetamol", quantity: 2, price: 500.00),
          OpenStruct.new(name: "Vitamin C", quantity: 1, price: 1000.00)
        ]
      )
      
      OrderMailer.with(order: mock_order).order_created_email
    end
  end

  def order_status_updated_email
    # Get a sample order for preview
    order = Pharmacy::SephcoccoPharmacyOrder.first || 
            Restaurant::SephcoccoRestaurantOrder.first || 
            Lounge::SephcoccoLoungeOrder.first
    
    if order
      OrderMailer.with(order: order, old_status: "pending").order_status_updated_email
    else
      # Create a mock order for preview
      mock_order = OpenStruct.new(
        order_number: "ORD-123456",
        status: "delivering",
        total_price: 15000.00,
        created_at: Time.current,
        updated_at: Time.current,
        sephcocco_user: OpenStruct.new(name: "John Doe", email: "john@example.com")
      )
      
      OrderMailer.with(order: mock_order, old_status: "processing").order_status_updated_email
    end
  end

  def order_delivered_email
    # Get a sample order for preview
    order = Pharmacy::SephcoccoPharmacyOrder.first || 
            Restaurant::SephcoccoRestaurantOrder.first || 
            Lounge::SephcoccoLoungeOrder.first
    
    if order
      OrderMailer.with(order: order).order_delivered_email
    else
      # Create a mock order for preview
      mock_order = OpenStruct.new(
        order_number: "ORD-123456",
        status: "completed",
        total_price: 15000.00,
        created_at: Time.current,
        updated_at: Time.current,
        sephcocco_user: OpenStruct.new(name: "John Doe", email: "john@example.com")
      )
      
      OrderMailer.with(order: mock_order).order_delivered_email
    end
  end

  def order_cancelled_email
    # Get a sample order for preview
    order = Pharmacy::SephcoccoPharmacyOrder.first || 
            Restaurant::SephcoccoRestaurantOrder.first || 
            Lounge::SephcoccoLoungeOrder.first
    
    if order
      OrderMailer.with(order: order, reason: "Out of stock").order_cancelled_email
    else
      # Create a mock order for preview
      mock_order = OpenStruct.new(
        order_number: "ORD-123456",
        status: "cancelled",
        total_price: 15000.00,
        created_at: Time.current,
        updated_at: Time.current,
        sephcocco_user: OpenStruct.new(name: "John Doe", email: "john@example.com")
      )
      
      OrderMailer.with(order: mock_order, reason: "Out of stock").order_cancelled_email
    end
  end
end
