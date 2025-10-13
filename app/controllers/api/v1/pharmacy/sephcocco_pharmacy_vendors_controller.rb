class Api::V1::Pharmacy::SephcoccoPharmacyVendorsController < ApplicationController
  include Api::V1::Concerns::VendorControllerHelper

  private

  def vendor_class
    Pharmacy::SephcoccoPharmacyVendor
  end

  def vendor_param_key
    :sephcocco_pharmacy_vendor
  end

  def vendor_serializer
    Pharmacy::SephcoccoPharmacyVendorSerializer
  end
end
