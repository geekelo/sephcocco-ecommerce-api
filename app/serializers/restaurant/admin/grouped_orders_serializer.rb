# frozen_string_literal: true

module Restaurant
  module Admin
    class GroupedOrdersSerializer < ActiveModel::Serializer
      attributes :grouped_orders

      def grouped_orders
        orders = object.respond_to?(:to_a) ? object.to_a : Array(object)

        orders
          .group_by(&:order_number)
          .map do |order_number, os|
            customer = os.first&.sephcocco_user

            payment_status, payment_details = payment_summary_for(os)

            {
              order_number: order_number,
              customer: customer ? serialize_customer(customer) : nil,
              total_price: os.sum { |o| o.total_price.to_d },
              total_quantity: os.sum(&:quantity),
              payment_status: payment_status,
              payment_details: payment_details,
              orders: os.map { |o| serialize_order(o) },
            }
          end
      end

      private

      def serialize_order(order)
        prod = order.sephcocco_restaurant_product
        {
          id: order.id,
          order_number: order.order_number,
          status: order.status,
          current_stage: order.current_stage,
          stages: order.stages,
          quantity: order.quantity,
          unit_price: order.unit_price,
          total_cost: order.total_cost,
          total_price: order.total_price,
          created_at: order.created_at,
          updated_at: order.updated_at,
          product_details: prod ? {
            id: prod.id,
            name: prod.name,
            main_image_url: prod.main_image_url
          } : nil
        }
      end

      def serialize_customer(user)
        {
          id: user.id,
          name: user.name,
          email: user.email,
          phone_number: user.phone_number,
          address: user.address,
          subroles: user.sephcocco_user_subroles.pluck(:name)
        }
      end

      # Returns [label, payment_details_or_nil]
      def payment_summary_for(orders)
        payments = orders.map(&:sephcocco_restaurant_payment)
        non_nil_payments = payments.compact
        payment_ids = non_nil_payments.map(&:id).uniq
        statuses = non_nil_payments.map(&:status)

        return ["PENDING PAYMENT", nil] if payments.any?(&:nil?) || statuses.uniq.length != 1

        status = statuses.first
        label =
          if status == "paid"
            "PAID"
          elsif status == "payment confirmed"
            "PAYMENT CONFIRMED"
          else
            "PENDING PAYMENT"
          end

        return ["PENDING PAYMENT", nil] if label == "PENDING PAYMENT"
        return [label, nil] unless payment_ids.length == 1

        [label, non_nil_payments.first]
      end
    end
  end
end

