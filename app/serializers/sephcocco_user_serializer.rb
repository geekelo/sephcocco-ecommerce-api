class SephcoccoUserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :address, :phone_number, :whatsapp_number, :role, :outlets, :created_at, :updated_at

  def role
    object&.sephcocco_user_role&.name
  end

  def outlets
    object&.sephcocco_outlets&.map do |outlet|
      {
        name: outlet.name
      }
    end || []
  end
end
