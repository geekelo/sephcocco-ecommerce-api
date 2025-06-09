class Pharmacy::Admin::SephcoccoPharmacyMessageSerializer < ActiveModel::Serializer
  attributes :id, :chats, :status, :user_id

  def user_id
    object.sephcocco_user_id
  end
end
