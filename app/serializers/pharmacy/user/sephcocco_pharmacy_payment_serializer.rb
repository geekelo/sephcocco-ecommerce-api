class Pharmacy::User::SephcoccoPharmacyPaymentSerializer < ActiveModel::Serializer
    attributes  :id,
              :amount,
              :status,
              :created_at,
              :updated_at,
              :sephcocco_user_id,
              :transaction_id,
              :payment_method,
              :delivery_location,
              :orders

  attribute :paid_orders
  attribute :orders_details

  def orders_details
    return [] unless object.orders.is_a?(Array)
    
    object.orders.map do |order_id|
      begin
        order = Pharmacy::SephcoccoPharmacyOrder.find(order_id)
        {
          id: order.id,
          order_number: order.order_number,
          status: order.status,
          total_price: order.total_price,
          quantity: order.quantity,
          unit_price: order.unit_price,
          total_cost: order.total_cost,
          created_at: order.created_at,
          product: {
            id: order.sephcocco_pharmacy_product.id,
            name: order.sephcocco_pharmacy_product.name,
            main_image_url: order.sephcocco_pharmacy_product.main_image_url,
            unit_price: order.sephcocco_pharmacy_product.unit_price,
          },
        }
      rescue ActiveRecord::RecordNotFound
        { id: order_id, error: "Order not found" }
      end
    end
  end
  def paid_orders
    return [] unless object.orders.is_a?(Array)
    
    object.orders.map do |order_id|
      begin
        order = Pharmacy::SephcoccoPharmacyOrder.find(order_id)
        {
          id: order.id,
          order_number: order.order_number,
          status: order.status,
          total_price: order.total_price,
          product_name: order.sephcocco_pharmacy_product.name,
        }
      rescue ActiveRecord::RecordNotFound
        { id: order_id, error: "Order not found" }
      end
    end
  end
end
