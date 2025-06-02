module Lounge
  module Messages
    class CreateService
      def initialize(user:, params:, product_id:, message_class:)
        @user = user
        @params = params
        @product_id = product_id
        @message_class = message_class
      end

      def call
        build_message
        return @message if @message.save

        raise ActiveRecord::RecordInvalid, @message
      end

      private

      def build_message
        @message = @message_class.new(
          sephcocco_user: admin? ? nil : @user,
          sephcocco_lounge_product_id: @product_id,
          chats: Array.wrap(@params[:chat]),
          status: "open",
          status_history: [ { "open" => Time.current } ],
        )
      end

      def admin?
        @user.sephcocco_user_role.name == "admin"
      end
    end
  end
end
