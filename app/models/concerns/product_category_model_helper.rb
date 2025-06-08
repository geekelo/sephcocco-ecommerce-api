module ProductCategoryModelHelper
  extend ActiveSupport::Concern

  included do
    before_create :create_slug
    before_update :create_slug, if: :saved_change_to_name?
  end

  def create_slug
    self.slug = name.parameterize if name.present?
  end

  module ClassMethods
    def setup_product_category_association
      has_and_belongs_to_many product_association_name,
                              join_table: join_table_name,
                              foreign_key: category_foreign_key,
                              association_foreign_key: product_foreign_key
    end

    def product_association_name
      raise NotImplementedError, "Define `self.product_association_name` in your model"
    end

    def join_table_name
      raise NotImplementedError, "Define `self.join_table_name` in your model"
    end

    def category_foreign_key
      raise NotImplementedError, "Define `self.category_foreign_key` in your model"
    end

    def product_foreign_key
      raise NotImplementedError, "Define `self.product_foreign_key` in your model"
    end
  end
end
