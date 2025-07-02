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
      @message_class.create!(
        title: @params[:title],
        answer: @params[:answer],
        visibility: @params[:visibility]
        position: @params[:position],
        update_history: [ history_entry("created") ],
        category_key => @params[category_key]
      )
    end

    private

    def history_entry(action)
      "#{Time.current}: #{action} by #{@user.name}"
    end
  end
end
