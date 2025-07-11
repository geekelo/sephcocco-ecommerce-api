class Lounge::User::SephcoccoLoungePaymentSerializer < ActiveModel::Serializer
  attributes :id, :amount, :status, :created_at, :transaction_id, :updated_at, :sephcocco_user_id, :orders,
              :paid_orders

  def paid_orders
    object.orders.map do |order|
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
    end
  end
end
