class Api::V1::Restaurant::SephcoccoRestaurantFaqsController < ApplicationController
  include Api::V1::Concerns::FaqsControllerHelper

  before_action :authenticate_user!

  private

  def message_class
    Restaurant::SephcoccoRestaurantFaq
  end

  def outlet
    "restaurant"
  end

  def faq_serializer_class
    Restaurant::Admin::SephcoccoRestaurantFaqSerializer
  end

  def faq_category_class
    Restaurant::SephcoccoRestaurantFaqCategory
  end

  def faq_params
    params.require(:faq).permit(:title, :answer, :position, :visibility, :sephcocco_restaurant_faq_category_id)
  end
end
