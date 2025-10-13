class Lounge::SephcoccoLoungeVendor < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
