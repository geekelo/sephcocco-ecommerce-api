class Pharmacy::Admin::SephcoccoPharmacyPaymentSerializer < ActiveModel::Serializer
  attributes :id,
               :sephcocco_user_id,
               :amount,
               :status,
               :created_at,
               :updated_at,
               :transaction_id,
               :orders,
               :orders_details,
               :payment_method,
               :delivery_location

  attribute :paid_orders

  def orders_details
    object.sephcocco_pharmacy_orders.map do |order|
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
          created_at: order.created_at,
          product: Pharmacy::Admin::SephcoccoPharmacyProductSerializer.new(order.sephcocco_pharmacy_product).as_json,
          customer: {
            id: order.sephcocco_user.id,
            name: order.sephcocco_user.name,
            email: order.sephcocco_user.email,
            phone_number: order.sephcocco_user.phone_number,
            address: order.sephcocco_user.address,
          },
        }
      rescue ActiveRecord::RecordNotFound
        { id: order_id, error: "Order not found" }
      end
    end
  end
end
