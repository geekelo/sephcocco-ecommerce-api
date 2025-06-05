
module Messages
  class CreateService
    def initialize(user:, params:, product_id:, message_class:, outlet:)
      @user = user
      @params = params
      @product_id = product_id
      @message_class = message_class
      @outlet = outlet
    end

    def call
      build_message
      return @message if @message.save

      raise ActiveRecord::RecordInvalid, @message
    end

    private

    def build_message
      product_key = "sephcocco_#{@outlet.downcase}_product_id"
      @message = @message_class.new(
        sephcocco_user: admin? ? nil : @user,
        product_key => @product_id,
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
