module Pharmacy
  module AdminNotifications
    class CreateService
      def initialize(action_type:, action_id:, user:, notification_class:)
        @action_type = action_type
        @action_id = action_id
        @user = user
        @notification_class = notification_class
      end

      def call
        # Logic to create admin notification for the order
        @notification_class.create!(
          sephcocco_user: @user,
          action_type: @action_type,
          action_id: @action_id,
          message: generate_message,
          viewed: false,
          visible: true
        )

      end

      def generate_message
          "New #{@action_type} created at #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}."
      end
    end
  end
end
