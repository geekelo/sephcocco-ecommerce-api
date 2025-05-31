module Lounge
  module Messages
    class UpdateService
      def initialize(user:, message_id:, params:)
        @user = user
        @message_id = message_id
        @params = params
      end

      def call
        @message = Lounge::SephcoccoLoungeMessage.find(@message_id)

        raise ActiveRecord::RecordNotFound unless authorized?

        update_message
        return @message if @message.save

        raise ActiveRecord::RecordInvalid, @message
      end

      private

      def update_message
        if @params[:chat].present?
          @message.chats << @params[:chat]
        end

        if @params[:status].present? && @message.status != @params[:status]
          @message.status = @params[:status]
          @message.status_history << { @params[:status] => Time.current }
        end
      end

      def authorized?
        # only allow admin or owner to update
        @user.sephcocco_user_role.name == 'admin' || @message.sephcocco_user_id == @user.id
      end
    end
  end
end
