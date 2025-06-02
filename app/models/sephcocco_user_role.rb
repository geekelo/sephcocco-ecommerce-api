class SephcoccoUserRole < ApplicationRecord
  has_many :sephcocco_users

  validates :name, presence: true, uniqueness: true
end
