# app/models/sephcocco_outlet.rb
class SephcoccoOutlet < ApplicationRecord
  has_and_belongs_to_many :sephcocco_users
end
