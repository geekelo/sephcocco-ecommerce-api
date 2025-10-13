class SephcoccoLocationSerializer < ActiveModel::Serializer
  attributes :id, :location, :logistics_price, :created_at, :updated_at
end
