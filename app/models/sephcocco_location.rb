class SephcoccoLocation < ApplicationRecord
  validates :location, presence: true, uniqueness: true
  validates :logistics_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
