class Api::V1::Restaurant::SephcoccoRestaurantVendorsController < ApplicationController
  include Api::V1::Concerns::VendorControllerHelper

  private

  def vendor_class
    Restaurant::SephcoccoRestaurantVendor
  end

  def vendor_param_key
    :sephcocco_restaurant_vendor
  end

  def vendor_serializer
    Restaurant::SephcoccoRestaurantVendorSerializer
  end
end
