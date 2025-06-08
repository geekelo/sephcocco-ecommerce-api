class Pharmacy::Admin::SephcoccoPharmacyFaqCategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :position, :visibility

  def faqs
    object.sephcocco_pharmacy_faqs.order(:position).map do |faq|
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
