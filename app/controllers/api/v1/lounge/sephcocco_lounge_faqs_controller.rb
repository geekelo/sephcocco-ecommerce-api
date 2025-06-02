class Api::V1::Lounge::SephcoccoLoungeFaqsController < ApplicationController
  include Api::V1::Concerns::MessageControllerHelper
  
  before_action :authenticate_user!
  
  private
  
  def message_class
    Lounge::SephcoccoLoungeFaq
  end

  def faq_serializer_class_admin
    Lounge::Admin::SephcoccoLoungeFaqSerializer
  end

  def faq_serializer_class_user
    Lounge::User::SephcoccoLoungeFaqSerializer
  end

  def faq_category_class
    Lounge::SephcoccoLoungeFaqCategory
  end

  def faq_category_association
    :sephcocco_lounge_faq_categories
  end

  def faq_params
    params.require(:faq).permit(:title, :answer, :position, :visibility, :faq_category_id)
  end
end
