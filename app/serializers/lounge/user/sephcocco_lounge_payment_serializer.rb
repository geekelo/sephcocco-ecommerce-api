class Lounge::User::SephcoccoLoungePaymentSerializer < ActiveModel::Serializer
  attributes :id, :amount, :status, :created_at, :updated_at, :sephcocco_user_id
end
