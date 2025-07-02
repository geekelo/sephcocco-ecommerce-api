module Faqs
  class CreateService
    def initialize(user:, params:, message_class:, outlet:)
      @user = user
      @params = params
      @message_class = message_class
      @outlet = outlet.downcase
    end

    def call
      category_key = :"sephcocco_#{@outlet}_faq_category_id"
      
      # Debug logging
      Rails.logger.info "FAQ Create Service - Params: #{@params.inspect}"
      Rails.logger.info "FAQ Create Service - Category Key: #{category_key}"
      Rails.logger.info "FAQ Create Service - Category ID: #{@params[category_key]}"
      
      create_params = {
        title: @params[:title],
        answer: @params[:answer],
        visibility: @params[:visibility],
        position: @params[:position],
        update_history: { "created" => history_entry("created") },
        category_key => @params[category_key]
      }
      
      Rails.logger.info "FAQ Create Service - Create Params: #{create_params.inspect}"
      
      @message_class.create!(create_params)
    end

    private

    def history_entry(action)
      "#{Time.current}: #{action} by #{@user.name}"
    end
  end
end
