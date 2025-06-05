class Lounge::Admin::SephcoccoRestaurantMessageSerializer < ActiveModel::Serializer
  attributes :id, :chats, :status, :user_id

  def user_id
    object.sephcocco_user_id
  end
end
