module Lounge
  module Faqs
    class CreateService
      def initialize(user:, params:, message_class:)
        @user = user
        @params = params
        @message_class = message_class
      end

      def call
        @message_class.create!(
          title: @params[:title],
          answer: @params[:answer],
          visibility: @params[:visibility],
          position: @params[:position],
          update_history: [history_entry("created")],
          sephcocco_lounge_faq_category_id: @params[:sephcocco_lounge_faq_category_id]
        )
      end

      private

      def history_entry(action)
        "#{Time.current}: #{action} by #{@user.name}"
      end
    end
  end
end
