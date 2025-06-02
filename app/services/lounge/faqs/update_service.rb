module Lounge
  module Faqs
    class UpdateService
      def initialize(user:, faq_id:, params:, message_class:)
        @user = user
        @faq_id = faq_id
        @params = params
        @message_class = message_class
      end

      def call
        faq = @message_class.find(@faq_id)
        faq.assign_attributes(permitted_attributes)

        # Append to update history
        history = faq.update_history || []
        history << history_entry("updated")
        faq.update_history = history

        faq.save!
        faq
      end

      private

      def permitted_attributes
        @params.slice(
          :title,
          :answer,
          :visibility,
          :position,
          :sephcocco_lounge_faq_category_id
        )
      end

      def history_entry(action)
        "#{Time.current}: #{action} by #{@user.name}"
      end
    end
  end
end
