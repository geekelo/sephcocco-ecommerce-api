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
    
    # Create standardized broadcast data
    broadcast_data = {
      type: 'new_message',
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
      status: @message.status,
      outlet_type: 'lounge',
      message_thread_id: @message.id,
      user_id: @message.sephcocco_user_id
    }
    
    # Broadcast to the specific user
    ActionCable.server.broadcast(
      "messaging_user_#{@message.sephcocco_user_id}",
      broadcast_data
    )
    
    # Broadcast to admin channel
    ActionCable.server.broadcast(
      "messaging_admin_lounge",
      broadcast_data
    )
  end

  def broadcast_pharmacy_message
    # Get the latest chat from the message thread
    latest_chat = @message.chats.last
    
    # Create standardized broadcast data
    broadcast_data = {
      type: 'new_message',
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
      status: @message.status,
      outlet_type: 'pharmacy',
      message_thread_id: @message.id,
      user_id: @message.sephcocco_user_id
    }
    
    # Broadcast to the specific user
    ActionCable.server.broadcast(
      "messaging_user_#{@message.sephcocco_user_id}",
      broadcast_data
    )
    
    # Broadcast to admin channel
    ActionCable.server.broadcast(
      "messaging_admin_pharmacy",
      broadcast_data
    )
  end

  def broadcast_restaurant_message
    # Get the latest chat from the message thread
    latest_chat = @message.chats.last
    
    # Create standardized broadcast data
    broadcast_data = {
      type: 'new_message',
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
      status: @message.status,
      outlet_type: 'restaurant',
      message_thread_id: @message.id,
      user_id: @message.sephcocco_user_id
    }
    
    # Broadcast to the specific user
    ActionCable.server.broadcast(
      "messaging_user_#{@message.sephcocco_user_id}",
      broadcast_data
    )
    
    # Broadcast to admin channel
    ActionCable.server.broadcast(
      "messaging_admin_restaurant",
      broadcast_data
    )
  end
end 