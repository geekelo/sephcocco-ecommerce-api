# app/models/concerns/product_like_model_helper.rb
module Api::V1::Concerns::ProductLikeModelHelper
  extend ActiveSupport::Concern

  module ClassMethods
    def setup_product_like_associations
      belongs_to :user,
                 class_name: user_class_name,
                 foreign_key: user_foreign_key

      belongs_to :product,
                 class_name: product_class_name,
                 foreign_key: product_foreign_key
    end

    def user_class_name
      raise NotImplementedError, "Define self.user_class_name in your model"
    end

    def product_class_name
      raise NotImplementedError, "Define self.product_class_name in your model"
    end

    def user_foreign_key
      raise NotImplementedError, "Define self.user_foreign_key in your model"
    end

    def product_foreign_key
      raise NotImplementedError, "Define self.product_foreign_key in your model"
    end
  end
end
