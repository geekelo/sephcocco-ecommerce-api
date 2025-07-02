module Faqs
  class CreateService
    def initialize(user:, params:, faq_class:, outlet:)
      @user = user
      @params = params
      @faq_class = faq_class
      @outlet = outlet.downcase
    end

    def call
      category_key = :"sephcocco_#{@outlet}_faq_category_id"
      
      create_params = {
        title: @params[:title],
        answer: @params[:answer],
        visibility: @params[:visibility],
        position: @params[:position],
        update_history: { "created" => history_entry("created") },
        category_key => @params[category_key]
      }
      
      Rails.logger.info "FAQ Create Service - Create Params: #{create_params.inspect}"
      
      @faq_class.create!(create_params)
    end

    private

    def history_entry(action)
      "#{Time.current}: #{action} by #{@user.name}"
    end
  end
end
