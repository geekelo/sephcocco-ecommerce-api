class Api::V1::Pharmacy::SephcoccoPharmacyFaqsController < ApplicationController
  include Api::V1::Concerns::FaqsControllerHelper

  before_action :authenticate_user!

  private

  def faq_class
    Pharmacy::SephcoccoPharmacyFaq
  end

  def outlet
    "pharmacy"
  end

  def faq_serializer_class
    Pharmacy::Admin::SephcoccoPharmacyFaqSerializer
  end

  def faq_category_class
    Pharmacy::SephcoccoPharmacyFaqCategory
  end

  def faq_params
    params.require(:faq).permit(:title, :answer, :position, :visibility, :sephcocco_pharmacy_faq_category_id)
  end
end
