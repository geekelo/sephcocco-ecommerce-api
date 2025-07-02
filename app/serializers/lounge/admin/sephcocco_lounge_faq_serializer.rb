class Lounge::Admin::SephcoccoLoungeFaqSerializer < ActiveModel::Serializer
  attributes :id, :title, :answer, :visibility, :position, :update_history, :created_at, :updated_at

  belongs_to :sephcocco_lounge_faq_category, serializer: Lounge::Admin::SephcoccoLoungeFaqCategorySerializer
end 