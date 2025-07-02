module Faqs
  class UpdateService
    def initialize(user:, faq_id:, params:, faq_class:, outlet:)
      @user = user
      @faq_id = faq_id
      @params = params
      @faq_class = faq_class
      @outlet = outlet.downcase
    end

    def call
      Rails.logger.info "FAQ Update Service - Looking for FAQ with ID: #{@faq_id}"
      Rails.logger.info "FAQ Update Service - FAQ Class: #{@faq_class}"
      
      faq = @faq_class.find(@faq_id)
      Rails.logger.info "FAQ Update Service - Found FAQ: #{faq.inspect}"
      
      faq.assign_attributes(permitted_attributes)

      # Append to update history
      history = faq.update_history || {}
      history["updated"] = history_entry("updated")
      faq.update_history = history

      faq.save!
      faq
    end

    private

    def permitted_attributes
      category_key = :"sephcocco_#{@outlet}_faq_category_id"
      
      Rails.logger.info "FAQ Update Service - Category Key: #{category_key}"
      Rails.logger.info "FAQ Update Service - Params: #{@params.inspect}"
      
      permitted = @params.slice(
        :title,
        :answer,
        :visibility,
        :position,
        category_key
      )
      
      Rails.logger.info "FAQ Update Service - Permitted Attributes: #{permitted.inspect}"
      permitted
    end

    def history_entry(action)
      "#{Time.current}: #{action} by #{@user.name}"
    end
  end
end
