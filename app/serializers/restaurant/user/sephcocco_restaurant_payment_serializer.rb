class Restaurant::User::SephcoccoRestaurantPaymentSerializer < ActiveModel::Serializer
  attributes  :id, :amount, :status, :created_at, :transaction_id, :updated_at, :sephcocco_user_id, :orders

  attribute :paid_orders

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
          product: {
            id: order.sephcocco_restaurant_product.id,
            name: order.sephcocco_restaurant_product.name,
            main_image_url: order.sephcocco_restaurant_product.main_image_url,
          },
        }
      rescue ActiveRecord::RecordNotFound
        { id: order_id, error: "Order not found" }
      end
    end
  end
end
