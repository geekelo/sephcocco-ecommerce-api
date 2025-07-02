class Lounge::User::SephcoccoLoungeFaqSerializer < ActiveModel::Serializer
  attributes :id, :title, :answer, :position, :created_at

  belongs_to :sephcocco_lounge_faq_category, serializer: Lounge::User::SephcoccoLoungeFaqCategorySerializer
end 