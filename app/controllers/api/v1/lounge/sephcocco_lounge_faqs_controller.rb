class Api::V1::Lounge::SephcoccoLoungeFaqsController < ApplicationController
  include Api::V1::Concerns::FaqsControllerHelper

  before_action :authenticate_user!

  private

  def message_class
    Lounge::SephcoccoLoungeFaq
  end

  def outlet
    "lounge"
  end

  def faq_serializer_class
    Lounge::Admin::SephcoccoLoungeFaqSerializer
  end

  def faq_category_class
    Lounge::SephcoccoLoungeFaqCategory
  end

  def faq_params
    params.require(:faq).permit(:title, :answer, :position, :visibility, :sephcocco_lounge_faq_category_id)
  end
end
