class Api::V1::Lounge::User::SephcoccoLoungeFaqCategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :position, :visibility

  def faqs
    object.sephcocco_lounge_faqs.where(visibility: true).order(:position).map do |faq|
      {
        id: faq.id,
        title: faq.title,
        answer: faq.answer,
      }
    end
  end
end
