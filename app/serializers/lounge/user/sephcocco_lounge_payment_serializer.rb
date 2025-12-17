class Lounge::User::SephcoccoLoungePaymentSerializer < ActiveModel::Serializer
  attributes :id,
             :amount,
             :status,
             :created_at,
             :transaction_id,
             :updated_at,
             :sephcocco_user_id,
             :orders,
             :payment_method,
             :delivery_location

  attribute :paid_orders
  attribute :orders_details
  
  def orders_details
    object.sephcocco_lounge_orders.map do |order|
      {
        id: order.id,
        order_number: order.order_number,
        status: order.status,
      }
    end
  end
  def paid_orders
    return [] unless object.orders.is_a?(Array)
    
    object.orders.map do |order_id|
      begin
        order = Lounge::SephcoccoLoungeOrder.find(order_id)
        {
          id: order.id,
          order_number: order.order_number,
          status: order.status,
          total_price: order.total_price,
          created_at: order.created_at,
          product: {
            id: order.sephcocco_lounge_product.id,
            name: order.sephcocco_lounge_product.name,
            main_image_url: order.sephcocco_lounge_product.main_image_url,
          },
        }
      rescue ActiveRecord::RecordNotFound
        { id: order_id, error: "Order not found" }
      end
    end
  end
end
