class Pharmacy::User::SephcoccoPharmacyPaymentSerializer < ActiveModel::Serializer
  attributes  :id,
              :name,
              :image_url,
              :short_description,
              :long_description,
              :other_images,
              :amount_in_stock,
              :likes,
              :liked_by_user,
              :price,
              :created_at,
              :updated_at,

  def liked_by_user
    # You need access to current_user, usually via serialization context
    current_user = scope || instance_options[:current_user]
    object.likers.exists?(id: current_user.id) if current_user
  end
end
