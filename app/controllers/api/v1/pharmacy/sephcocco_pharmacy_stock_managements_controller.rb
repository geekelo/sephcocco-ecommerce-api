class Api::V1::Pharmacy::SephcoccoPharmacyStockManagementsController < ApplicationController
  include Api::V1::Concerns::StockManagementControllerHelper

  private

  def stock_management_class
    Pharmacy::SephcoccoPharmacyStockManagement
  end

  def stock_management_serializer
    Pharmacy::Admin::SephcoccoPharmacyStockManagementSerializer
  end

  def outlet
    'pharmacy'
  end
end
