class SephcoccoUser < ApplicationRecord
  has_secure_password
  belongs_to :sephcocco_user_role, optional: true
  has_and_belongs_to_many :sephcocco_outlets
  
  # Lounge associations
  has_many :lounge_product_likes, class_name: "Lounge::SephcoccoLoungeProductLike", foreign_key: :sephcocco_user_id, dependent: :destroy
  has_many :liked_lounge_products, through: :lounge_product_likes, source: :sephcocco_lounge_product
  has_many :lounge_orders, class_name: "SephcoccoLoungeOrder", foreign_key: :sephcocco_user_id
  has_many :ordered_lounge_products, through: :lounge_orders, source: :sephcocco_lounge_product
  has_many :sephcocco_lounge_orders, class_name: "Lounge::SephcoccoLoungeOrder", foreign_key: :sephcocco_user_id
  has_many :sephcocco_lounge_admin_activities, class_name: "Lounge::SephcoccoLoungeAdminActivity", foreign_key: :sephcocco_user_id
  has_many :sephcocco_lounge_messages, class_name: "Lounge::SephcoccoLoungeMessage", foreign_key: :sephcocco_user_id

  # Restaurant associations
  has_many :restaurant_product_likes, class_name: "Restaurant::SephcoccoRestaurantProductLike", foreign_key: :sephcocco_user_id, dependent: :destroy
  has_many :liked_restaurant_products, through: :restaurant_product_likes, source: :sephcocco_restaurant_product
  has_many :restaurant_orders, class_name: "SephcoccoRestaurantOrder", foreign_key: :sephcocco_user_id
  has_many :ordered_restaurant_products, through: :restaurant_orders, source: :sephcocco_restaurant_product
  has_many :sephcocco_restaurant_orders, class_name: "Restaurant::SephcoccoRestaurantOrder", foreign_key: :sephcocco_user_id
  has_many :sephcocco_restaurant_admin_activities, class_name: "Restaurant::SephcoccoRestaurantAdminActivity", foreign_key: :sephcocco_user_id
  has_many :sephcocco_restaurant_messages, class_name: "Restaurant::SephcoccoRestaurantMessage", foreign_key: :sephcocco_user_id

  # Pharmacy associations
  has_many :pharmacy_product_likes, class_name: "Pharmacy::SephcoccoPharmacyProductLike", foreign_key: :sephcocco_user_id, dependent: :destroy
  has_many :liked_pharmacy_products, through: :pharmacy_product_likes, source: :sephcocco_pharmacy_product
  has_many :pharmacy_orders, class_name: "SephcoccoPharmacyOrder", foreign_key: :sephcocco_user_id
  has_many :ordered_pharmacy_products, through: :pharmacy_orders, source: :sephcocco_pharmacy_product
  has_many :sephcocco_pharmacy_orders, class_name: "Pharmacy::SephcoccoPharmacyOrder", foreign_key: :sephcocco_user_id
  has_many :sephcocco_pharmacy_admin_activities, class_name: "Pharmacy::SephcoccoPharmacyAdminActivity", foreign_key: :sephcocco_user_id
  has_many :sephcocco_pharmacy_messages, class_name: "Pharmacy::SephcoccoPharmacyMessage", foreign_key: :sephcocco_user_id
  
  # Payment associations
  has_many :sephcocco_lounge_payments, class_name: "Lounge::SephcoccoLoungePayment", foreign_key: :sephcocco_user_id
  has_many :sephcocco_restaurant_payments, class_name: "Restaurant::SephcoccoRestaurantPayment", foreign_key: :sephcocco_user_id
  has_many :sephcocco_pharmacy_payments, class_name: "Pharmacy::SephcoccoPharmacyPayment", foreign_key: :sephcocco_user_id
  
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

  def clear_reset_generated_token!
    update!(reset_password_token: nil, reset_password_sent_at: nil)
  end
end
