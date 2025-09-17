class Restaurant::Admin::SephcoccoRestaurantStockManagementSerializer < ActiveModel::Serializer
  attributes :id, :invoice_number, :vendor, :status, :product, :stock, :price, :created_at, :updated_at

  def stock
    {
      old_stock: object.stock['old_stock'],
      add_stock: object.stock['add_stock'],
      new_stock: object.stock['new_stock']
    }
  end

  def product
    {
      id: object&.sephcocco_restaurant_product&.id,
      name: object&.sephcocco_restaurant_product&.name,
      barcode: object&.sephcocco_restaurant_product&.barcode,
      main_image_url: object&.sephcocco_restaurant_product&.main_image_url,
    }
  end

  def price
    {
      old_price: object.price['old_price'],
      new_price: object.price['new_price'],
      cost_price: object.price['cost_price'],
      profit_markup: object.price['profit_markup']
    }
  end

  belongs_to :sephcocco_restaurant_product, serializer: Restaurant::SephcoccoRestaurantProductSerializer
end
