class Lounge::Admin::SephcoccoLoungePaymentSerializer < ActiveModel::Serializer
  attributes :id,
               :sephcocco_user_id,
               :amount,
               :status,
               :created_at,
               :updated_at,
               :transaction_id,
               :orders,
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
        customer: {
          id: order.sephcocco_user.id,
          name: order.sephcocco_user.name,
          email: order.sephcocco_user.email,
          phone_number: order.sephcocco_user.phone_number,
          address: order.sephcocco_user.address,
        },
      }
    end
  end
end
