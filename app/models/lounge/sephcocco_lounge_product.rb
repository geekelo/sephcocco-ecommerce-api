module Lounge
 class SephcoccoLoungeProduct < ApplicationRecord
  include ProductModelHelper

    def self.category_association_name
      :sephcocco_lounge_product_categories
    end
  
    def self.join_table_name
      :sephcocco_lounge_product_categories_products
    end
  
    def self.category_association_foreign_key_name
      :sephcocco_lounge_product_category_id
    end
  
    def self.category_product_foreign_key
      :sephcocco_lounge_product_id
    end

    def self.category_foreign_key
      :sephcocco_lounge_product_category_id
    end
  
    def self.product_foreign_key
      :sephcocco_lounge_product_id
    end
  
    def self.product_like_class
      Lounge::SephcoccoLoungeProductLike
    end
  
    def self.order_class
      Lounge::SephcoccoLoungeOrder
    end
  
    def self.likes_association_name
      :sephcocco_lounge_product_likes
    end
  
    def self.order_association_name
      :lounge_orders
    end
  
    # 🔧 Call the association setup after all class methods are defined
    setup_product_associations
  end
end
