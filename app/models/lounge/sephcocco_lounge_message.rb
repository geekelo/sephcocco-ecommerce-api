class Lounge::SephcoccoLoungeMessage < ApplicationRecord
  belongs_to :sephcocco_user, optional: true
  belongs_to :sephcocco_lounge_product
end
