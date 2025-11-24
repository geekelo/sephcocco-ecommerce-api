class Lounge::SephcoccoLoungePayment < ApplicationRecord
  include PaymentModelHelper

  belongs_to :sephcocco_user, class_name: "SephcoccoUser", foreign_key: :sephcocco_user_id, optional: true
  belongs_to :sephcocco_lounge_department, class_name: "Lounge::SephcoccoLoungeDepartment", optional: true
  has_many :sephcocco_lounge_orders, class_name: "Lounge::SephcoccoLoungeOrder", foreign_key: :sephcocco_lounge_payment_id

  def associated_order_class
    Lounge::SephcoccoLoungeOrder
  end
end
