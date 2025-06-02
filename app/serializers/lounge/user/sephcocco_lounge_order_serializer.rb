class Lounge::User::SephcoccoLoungeOrderSerializer < ActiveModel::Serializer
  attributes  :id,
              :status,
              :order_number,
              :quantity,
              :unit_price,
              :total_cost,
              :total_price,
              :created_at,
              :updated_at
end
