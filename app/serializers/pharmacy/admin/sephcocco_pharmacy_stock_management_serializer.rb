class Pharmacy::Admin::SephcoccoPharmacyStockManagementSerializer < ActiveModel::Serializer
  attributes :id, :invoice_number, :vendor, :department, :status, :product, :stock, :price, :created_at, :updated_at

  def vendor
    if object.sephcocco_pharmacy_vendor
      {
        id: object.sephcocco_pharmacy_vendor.id,
        name: object.sephcocco_pharmacy_vendor.name,
        email: object.sephcocco_pharmacy_vendor.email,
        phone: object.sephcocco_pharmacy_vendor.phone
      }
    end
  end

  def department
    if object.sephcocco_pharmacy_department
      {
        id: object.sephcocco_pharmacy_department.id,
        name: object.sephcocco_pharmacy_department.name
      }
    end
  end

  def stock
    {
      old_stock: object.stock['old_stock'],
      add_stock: object.stock['add_stock'],
      new_stock: object.stock['new_stock']
    }
  end

  def product
    {
      id: object&.sephcocco_pharmacy_product&.id,
      name: object&.sephcocco_pharmacy_product&.name,
      barcode: object&.sephcocco_pharmacy_product&.barcode,
      main_image_url: object&.sephcocco_pharmacy_product&.main_image_url,
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
end
