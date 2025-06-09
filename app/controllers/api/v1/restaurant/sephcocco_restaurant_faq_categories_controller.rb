class Api::V1::Restaurant::SephcoccoRestaurantFaqCategoriesController < ApplicationController
  include Api::V1::Concerns::FaqCategoriesControllerHelper

  private

  def faq_category_serializer
    Restaurant::Admin::SephcoccoRestaurantFaqCategorySerializer
  end

  def faq_category_association
    :sephcocco_restaurant_faq_categories
  end

  def faq_category_params
    params.require(:sephcocco_restaurant_faq_category).permit(
      :name,
      :description,
      :position,
      :visibility,
    )
  end
end
