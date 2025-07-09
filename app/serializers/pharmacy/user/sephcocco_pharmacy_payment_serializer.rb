class Pharmacy::User::SephcoccoPharmacyPaymentSerializer < ActiveModel::Serializer
  attributes  :id,
              :amount,
              :status,
              :created_at,
              :updated_at,
              :sephcocco_user_id,
              :transaction_id

  has_many :orders, serializer: Pharmacy::User::SephcoccoPharmacyOrderSerializer 
end
