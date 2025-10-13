class Api::V1::Lounge::SephcoccoLoungeVendorsController < ApplicationController
  include Api::V1::Concerns::VendorControllerHelper

  private

  def vendor_class
    Lounge::SephcoccoLoungeVendor
  end

  def vendor_param_key
    :sephcocco_lounge_vendor
  end

  def vendor_serializer
    Lounge::SephcoccoLoungeVendorSerializer
  end
end
