class SephcoccoUser < ApplicationRecord
  has_secure_password
  belongs_to :sephcocco_user_role, optional: true
  has_and_belongs_to_many :sephcocco_outlets
  has_many :lounge_product_likes, class_name: "SephcoccoLoungeProductLike", foreign_key: :sephcocco_user_id, dependent: :destroy
  has_many :liked_products, through: :lounge_product_likes, source: :sephcocco_lounge_product

  has_many :orders, class_name: "SephcoccoLoungeOrder", foreign_key: :sephcocco_user_id
  has_many :ordered_products, through: :orders, source: :sephcocco_lounge_product
end
