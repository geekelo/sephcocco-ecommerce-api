class SephcoccoUser < ApplicationRecord
  has_secure_password
  belongs_to :sephcocco_user_role, optional: true
  has_and_belongs_to_many :sephcocco_outlets
  has_many :lounge_product_likes, class_name: "SephcoccoLoungeProductLike", foreign_key: :sephcocco_user_id, dependent: :destroy
  has_many :liked_products, through: :lounge_product_likes, source: :sephcocco_lounge_product

  has_many :orders, class_name: "SephcoccoLoungeOrder", foreign_key: :sephcocco_user_id
  has_many :ordered_products, through: :orders, source: :sephcocco_lounge_product

  # password reset token
  def generate_password_reset_token!
    token = rand(100000..999999).to_s
    update!(
      reset_password_token: token,
      reset_password_sent_at: Time.current
    )
    token
  end

  # Checks if the password reset token has expired
  def password_reset_token_expired?
    reset_password_sent_at < 2.hours.ago
  end
end
