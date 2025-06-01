class Api::V1::Lounge::SephcoccoLoungeMessagesController < ApplicationController
  include Api::V1::Concerns::MessageControllerHelper

  private

  def message_class
    Lounge::SephcoccoLoungeMessage
  end

  def product_param_key
    :sephcocco_lounge_product_id
  end

  def product_foreign_key
    :sephcocco_lounge_product_id
  end

  def user_association_name
    :sephcocco_lounge_messages
  end

  def admin_serializer_class
    Lounge::Admin::SephcoccoLoungeMessageSerializer
  end

  def user_serializer_class
    Lounge::User::SephcoccoLoungeMessageSerializer
  end
end
