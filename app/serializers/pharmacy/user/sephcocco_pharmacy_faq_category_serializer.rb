class Pharmacy::User::SephcoccoPharmacyFaqCategorySerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :position, :visibility

  def faqs
    object.sephcocco_pharmacy_faqs.where(visibility: true).order(:position).map do |faq|
      {
        id: faq.id,
        title: faq.title,
        answer: faq.answer
      }
    end
  end
end
