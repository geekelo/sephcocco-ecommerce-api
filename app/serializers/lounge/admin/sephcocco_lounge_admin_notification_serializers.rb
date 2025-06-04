class Lounge::Admin::SephcoccoLoungeAdminNotificationSerializer < ActiveModel::Serializer
  attributes :id, :action_type, :action_id, :message, :viewed, :visible, :created_at,
  :user_id, :user_name, :user_email

  def user_id
    object&.sephcocco_user&.id
  end

  def user_name
    object&.sephcocco_user&.name
  end

  def user_email
    object&.sephcocco_user&.email
  end
end
