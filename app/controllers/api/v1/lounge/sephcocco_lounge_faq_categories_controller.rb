class Api::V1::Lounge::SephcoccoLoungeFaqCategoriesController < ApplicationController
  include Api::V1::Concerns::FaqCategoriesControllerHelper

  private

  def faq_category_serializer
    Lounge::Admin::SephcoccoLoungeFaqCategorySerializer
  end

  def faq_category_association
    :sephcocco_lounge_faq_categories
  end

  def faq_category_params
    params.require(:sephcocco_lounge_faq_category).permit(
      :name,
      :description,
      :position,
      :visibility,
    )
  end
end
