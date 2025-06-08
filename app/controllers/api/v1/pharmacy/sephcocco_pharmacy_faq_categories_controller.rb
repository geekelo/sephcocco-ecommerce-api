class Api::V1::Pharmacy::SephcoccoPharmacyFaqCategoriesController < ApplicationController
  include Api::V1::Concerns::FaqCategoriesControllerHelper

  private

  def faq_category_serializer
    Pharmacy::Admin::SephcoccoPharmacyFaqCategorySerializer
  end

  def faq_category_association
    :sephcocco_pharmacy_faq_categories
  end

  def faq_category_params
    params.require(:sephcocco_pharmacy_faq_category).permit(
      :name,
      :description,
      :position,
      :visibility,
    )
  end
end
