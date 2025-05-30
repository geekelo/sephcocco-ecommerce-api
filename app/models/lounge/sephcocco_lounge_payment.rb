class Lounge::SephcoccoLoungePayment < ApplicationRecord
  include PaymentModelHelper
  
  belongs_to :sephcocco_user, class_name: 'SephcoccoUser', foreign_key: :sephcocco_user_id, optional: true

  def associated_order_class
    Lounge::SephcoccoLoungeOrder
  end
end
