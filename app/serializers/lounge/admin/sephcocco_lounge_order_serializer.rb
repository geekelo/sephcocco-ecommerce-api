class Lounge::Admin::SephcoccoLoungeOrderSerializer < ActiveModel::Serializer
  
  attributes  :id,
              :sephcocco_user_id,
              :status,
              :stages,
              :order_number,
              :quantity,
              :unit_price,
              :total_cost,
              :total_price,
              :created_at,
              :updated_at
end
