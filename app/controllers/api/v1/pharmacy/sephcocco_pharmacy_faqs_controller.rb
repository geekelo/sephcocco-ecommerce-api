class Api::V1::Pharmacy::SephcoccoPharmacyFaqsController < ApplicationController
  include Api::V1::Concerns::MessageControllerHelper

  before_action :authenticate_user!

  private

  def message_class
    Pharmacy::SephcoccoPharmacyFaq
  end

  def outlet
    Pharmacy
  end

  def faq_serializer_class_admin
    Pharmacy::Admin::SephcoccoPharmacyFaqSerializer
  end

  def faq_serializer_class_user
    Pharmacy::User::SephcoccoPharmacyFaqSerializer
  end

  def faq_category_class
    Pharmacy::SephcoccoPharmacyFaqCategory
  end

  def faq_category_association
    :sephcocco_pharmacy_faq_categories
  end

  def faq_params
    params.require(:faq).permit(:title, :answer, :position, :visibility, :faq_category_id)
  end
end
