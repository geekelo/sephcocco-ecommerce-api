class Api::V1::Restaurant::SephcoccoRestaurantFaqsController < ApplicationController
  include Api::V1::Concerns::MessageControllerHelper

  before_action :authenticate_user!

  private

  def message_class
    Restaurant::SephcoccoRestaurantFaq
  end

  def outlet
    Restaurant
  end

  def faq_serializer_class_admin
    Restaurant::Admin::SephcoccoRestaurantFaqSerializer
  end

  def faq_serializer_class_user
    Restaurant::User::SephcoccoRestaurantFaqSerializer
  end

  def faq_category_class
    Restaurant::SephcoccoRestaurantFaqCategory
  end

  def faq_category_association
    :sephcocco_restaurant_faq_categories
  end

  def faq_params
    params.require(:faq).permit(:title, :answer, :position, :visibility, :faq_category_id)
  end
end
