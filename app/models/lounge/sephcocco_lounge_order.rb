class Lounge::SephcoccoLoungeOrder < ApplicationRecord
  include OrderModelHelper

  belongs_to :sephcocco_lounge_product
  belongs_to :sephcocco_user
  belongs_to :sephcocco_lounge_payment, optional: true

  # Alias to standardize the method used in the concern
  def product
    sephcocco_lounge_product
  end
end
