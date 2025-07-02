class Lounge::Admin::SephcoccoLoungeFaqCategorySerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :position, :visibility

  def faqs
    object.sephcocco_lounge_faqs.order(:position).map do |faq|
      {
        id: faq.id,
        title: faq.title,
        answer: faq.answer,
        visibility: faq.visibility,
        position: faq.position,
        update_history: faq.update_history
      }
    end
  end
end
