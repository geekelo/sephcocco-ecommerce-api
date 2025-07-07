class Api::V1::Pharmacy::SephcoccoPharmacyMessagesController < ApplicationController
  include Api::V1::Concerns::MessageControllerHelper

  private

  def message_class
    Pharmacy::SephcoccoPharmacyMessage
  end

  def outlet
    "pharmacy"
  end

  def product_param_key
    :sephcocco_pharmacy_product_id
  end

  def product_foreign_key
    :sephcocco_pharmacy_product_id
  end

  def user_association_name
    :sephcocco_pharmacy_messages
  end

  def admin_serializer_class
    Pharmacy::Admin::SephcoccoPharmacyMessageSerializer
  end

  def user_serializer_class
    Pharmacy::User::SephcoccoPharmacyMessageSerializer
  end
end
