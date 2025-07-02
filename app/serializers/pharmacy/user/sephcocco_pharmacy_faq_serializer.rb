class Pharmacy::User::SephcoccoPharmacyFaqSerializer < ActiveModel::Serializer
  attributes :id, :title, :answer, :position, :created_at

  belongs_to :sephcocco_pharmacy_faq_category, serializer: Pharmacy::User::SephcoccoPharmacyFaqCategorySerializer
end 