class Api::V1::Lounge::SephcoccoLoungeStockManagementsController < ApplicationController
  include Api::V1::Concerns::StockManagementControllerHelper

  private

  def stock_management_class
    Lounge::Admin::SephcoccoLoungeStockManagement
  end

  def stock_management_serializer
    Lounge::SephcoccoLoungeStockManagementSerializer
  end

  def outlet
    'lounge'
  end

  def product_class
    Lounge::SephcoccoLoungeProduct
  end
end
