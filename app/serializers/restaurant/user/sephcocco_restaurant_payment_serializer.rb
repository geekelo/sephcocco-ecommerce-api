class Restaurant::User::SephcoccoRestaurantPaymentSerializer < ActiveModel::Serializer
  attributes  :id,
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
    object.sephcocco_restaurant_orders.map do |order|
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
        order = Restaurant::SephcoccoRestaurantOrder.find(order_id)
        {
          id: order.id,
          order_number: order.order_number,
          status: order.status,
          total_price: order.total_price,
          created_at: order.created_at,
          product: order.sephcocco_restaurant_product_serializer.as_json
        }
      rescue ActiveRecord::RecordNotFound
        { id: order_id, error: "Order not found" }
      end
    end
  end
end
