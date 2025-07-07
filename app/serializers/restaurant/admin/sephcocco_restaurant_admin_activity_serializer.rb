module Restaurant
  module Admin
    class SephcoccoRestaurantAdminActivitySerializer < ActiveModel::Serializer
      attributes :id, :activity_type, :activity_name, :activity_description, :created_at, :updated_at

      belongs_to :sephcocco_user, serializer: SephcoccoUserSerializer
    end
  end
end 