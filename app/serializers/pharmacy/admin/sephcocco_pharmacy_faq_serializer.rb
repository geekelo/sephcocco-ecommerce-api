class Pharmacy::Admin::SephcoccoPharmacyFaqSerializer < ActiveModel::Serializer
  attributes :id, :title, :answer, :visibility, :position, :update_history, :created_at, :updated_at

  belongs_to :sephcocco_pharmacy_faq_category, serializer: Pharmacy::Admin::SephcoccoPharmacyFaqCategorySerializer
end 