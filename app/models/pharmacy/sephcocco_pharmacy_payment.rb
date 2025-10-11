class Pharmacy::SephcoccoPharmacyPayment < ApplicationRecord
  include PaymentModelHelper

  belongs_to :sephcocco_user, class_name: "SephcoccoUser", foreign_key: :sephcocco_user_id, optional: true
  belongs_to :sephcocco_pharmacy_department, class_name: "Pharmacy::SephcoccoPharmacyDepartment", optional: true
  has_many :sephcocco_pharmacy_orders, class_name: "Pharmacy::SephcoccoPharmacyOrder", foreign_key: :sephcocco_pharmacy_payment_id

  def associated_order_class
    Pharmacy::SephcoccoPharmacyOrder
  end
end
