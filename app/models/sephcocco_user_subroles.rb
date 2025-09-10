class SephcoccoUserSubrole < ApplicationRecord
  has_and_belongs_to_many :sephcocco_users
end