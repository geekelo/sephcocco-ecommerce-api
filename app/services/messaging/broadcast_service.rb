class Messaging::BroadcastService
  def initialize(message, outlet_type)
    @message = message
    @outlet_type = outlet_type
  end

  def call
    case @outlet_type
    when 'lounge'
      broadcast_lounge_message
    when 'pharmacy'
      broadcast_pharmacy_message
    when 'restaurant'
      broadcast_restaurant_message
    end
  end

  private

  def broadcast_lounge_message
    # Get the latest chat from the message thread
    latest_chat = @message.chats.last
    
    ActionCable.server.broadcast(
      "messaging_lounge",
      {
        id: @message.id,
        chat_id: latest_chat['id'],
        content: latest_chat['content'],
        user: {
          id: @message.sephcocco_user.id,
          name: @message.sephcocco_user.name,
          email: @message.sephcocco_user.email
        },
        created_at: latest_chat['timestamp'],
        message_type: latest_chat['message_type'] || 'text',
        status: @message.status
      }
    )
  end

  def broadcast_pharmacy_message
    # Get the latest chat from the message thread
    latest_chat = @message.chats.last
    
    ActionCable.server.broadcast(
      "messaging_pharmacy",
      {
        id: @message.id,
        chat_id: latest_chat['id'],
        content: latest_chat['content'],
        user: {
          id: @message.sephcocco_user.id,
          name: @message.sephcocco_user.name,
          email: @message.sephcocco_user.email
        },
        created_at: latest_chat['timestamp'],
        message_type: latest_chat['message_type'] || 'text',
        status: @message.status
      }
    )
  end

  def broadcast_restaurant_message
    # Get the latest chat from the message thread
    latest_chat = @message.chats.last
    
    ActionCable.server.broadcast(
      "messaging_restaurant",
      {
        id: @message.id,
        chat_id: latest_chat['id'],
        content: latest_chat['content'],
        user: {
          id: @message.sephcocco_user.id,
          name: @message.sephcocco_user.name,
          email: @message.sephcocco_user.email
        },
        created_at: latest_chat['timestamp'],
        message_type: latest_chat['message_type'] || 'text',
        status: @message.status
      }
    )
  end
end 