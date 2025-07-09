class Pharmacy::Admin::SephcoccoPharmacyPaymentSerializer < ActiveModel::Serializer
  attributes :id,
               :sephcocco_user_id,
               :amount,
               :status,
               :created_at,
               :updated_at,
               :transaction_id

  has_many :orders, serializer: Pharmacy::Admin::SephcoccoPharmacyOrderSerializer
end
