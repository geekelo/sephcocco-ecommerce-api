class Api::V1::Restaurant::SephcoccoRestaurantStockManagementsController < ApplicationController
  include Api::V1::Concerns::StockManagementControllerHelper

  private

  def stock_management_class
    Restaurant::SephcoccoRestaurantStockManagement
  end

  def stock_management_serializer
    Restaurant::Admin::SephcoccoRestaurantStockManagementSerializer
  end

  def outlet
    'restaurant'
  end
end
