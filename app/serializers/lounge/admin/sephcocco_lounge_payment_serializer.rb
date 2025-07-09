class Lounge::Admin::SephcoccoLoungePaymentSerializer < ActiveModel::Serializer
  attributes :id,
               :sephcocco_user_id,
               :amount,
               :status,
               :created_at,
               :updated_at,
               :transaction_id

  has_many :orders, serializer: Lounge::Admin::SephcoccoLoungeOrderSerializer
end
