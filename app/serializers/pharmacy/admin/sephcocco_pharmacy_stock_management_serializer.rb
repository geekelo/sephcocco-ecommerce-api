class Pharmacy::Admin::SephcoccoPharmacyStockManagementSerializer < ActiveModel::Serializer
  attributes :id, :invoice_number, :vendor, :status, :stock, :price, :created_at, :updated_at

  def stock
    {
      old_stock: object.stock['old_stock'],
      add_stock: object.stock['add_stock'],
      new_stock: object.stock['new_stock']
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
  belongs_to :sephcocco_pharmacy_product, serializer: Pharmacy::SephcoccoPharmacyProductSerializer
end
