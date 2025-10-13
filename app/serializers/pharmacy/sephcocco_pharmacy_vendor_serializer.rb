class Pharmacy::SephcoccoPharmacyVendorSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :phone, :address, :city, :state, :bank_details, :country, :created_at, :updated_at
end
