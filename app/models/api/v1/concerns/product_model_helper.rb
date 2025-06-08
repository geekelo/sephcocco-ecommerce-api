module ProductModelHelper
  extend ActiveSupport::Concern

  class_methods do
    def setup_product_associations
      has_and_belongs_to_many category_association_name,
                              join_table: join_table_name,
                              foreign_key: product_foreign_key,
                              association_foreign_key: category_foreign_key

      has_many likes_association_name,
               class_name: product_like_class.name,
               foreign_key: product_foreign_key,
               dependent: :destroy

      has_many :likers, through: likes_association_name, source: :sephcocco_user

      has_many order_association_name,
               class_name: order_class.name,
               foreign_key: product_foreign_key

      has_many :buyers, through: order_association_name, source: :sephcocco_user
    end

    def category_association_name
      raise NotImplementedError, "Define self.category_association_name"
    end

    def join_table_name
      raise NotImplementedError, "Define self.join_table_name"
    end

    def product_foreign_key
      raise NotImplementedError, "Define self.product_foreign_key"
    end

    def category_foreign_key
      raise NotImplementedError, "Define self.category_foreign_key"
    end

    def product_like_class
      raise NotImplementedError, "Define self.product_like_class"
    end

    def order_class
      raise NotImplementedError, "Define self.order_class"
    end

    def likes_association_name
      raise NotImplementedError, "Define self.likes_association_name"
    end

    def order_association_name
      raise NotImplementedError, "Define self.order_association_name"
    end
  end
end
