class Api::V1::Restaurant::SephcoccoRestaurantMessagesController < ApplicationController
  include Api::V1::Concerns::MessageControllerHelper

  private

  def message_class
    Restaurant::SephcoccoRestaurantMessage
  end

  def outlet
    "restaurant"
  end

  def product_param_key
    :sephcocco_restaurant_product_id
  end

  def product_foreign_key
    :sephcocco_restaurant_product_id
  end

  def user_association_name
    :sephcocco_restaurant_messages
  end

  def admin_serializer_class
    Restaurant::Admin::SephcoccoRestaurantMessageSerializer
  end

  def user_serializer_class
    Restaurant::User::SephcoccoRestaurantMessageSerializer
  end
end
