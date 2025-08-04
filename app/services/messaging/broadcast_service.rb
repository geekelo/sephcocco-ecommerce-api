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

  # Method to broadcast message updates specifically
  def broadcast_message_update
    case @outlet_type
    when 'lounge'
      broadcast_lounge_message_update
    when 'pharmacy'
      broadcast_pharmacy_message_update
    when 'restaurant'
      broadcast_restaurant_message_update
    end
  end

  private

  def broadcast_lounge_message
    # Get the latest chat from the message thread
    latest_chat = @message.chats.last
    
    Rails.logger.info "Broadcasting lounge message: #{@message.id}"
    Rails.logger.info "Message chats: #{@message.chats.inspect}"
    Rails.logger.info "Latest chat: #{latest_chat.inspect}"
    
    # Safety check for latest_chat
    if latest_chat.nil?
      Rails.logger.error "No latest chat found for message #{@message.id}"
      return
    end
    
    # Ensure latest_chat is a hash
    latest_chat = latest_chat.is_a?(String) ? JSON.parse(latest_chat) : latest_chat
    
    # Create standardized broadcast data
    broadcast_data = {
      type: 'new_message',
      id: @message.id,
      chat_id: latest_chat['id'] || SecureRandom.uuid,
      content: latest_chat['content'] || 'No content',
      user: {
        id: @message.sephcocco_user&.id || 'unknown',
        name: @message.sephcocco_user&.name || 'Unknown',
        email: @message.sephcocco_user&.email || '',
        role: @message.sephcocco_user&.sephcocco_user_role&.name || 'user'
      },
      created_at: latest_chat['timestamp'] || Time.current.iso8601,
      message_type: latest_chat['message_type'] || 'text',
      status: @message.status,
      outlet_type: 'lounge',
      message_thread_id: @message.id,
      user_id: @message.sephcocco_user_id,
      user_role: @message.sephcocco_user&.sephcocco_user_role&.name || 'user'
    }
    
    # Broadcast to the specific user
    user_channel = "messaging_user_#{@message.sephcocco_user_id}"
    Rails.logger.info "Broadcasting to user channel: #{user_channel}"
    ActionCable.server.broadcast(user_channel, broadcast_data)
    
    # Broadcast to admin channel
    admin_channel = "messaging_admin_lounge"
    Rails.logger.info "Broadcasting to admin channel: #{admin_channel}"
    ActionCable.server.broadcast(admin_channel, broadcast_data)
    
    # Also broadcast user thread update to admin
    Messaging::UserThreadService.new('lounge').broadcast_user_thread_update(
      @message, 
      latest_chat
    );
    
    # Broadcast message update event
    message_update_data = {
      type: 'message_updated',
      id: @message.id,
      user_id: @message.sephcocco_user_id,
      content: latest_chat['content'],
      created_at: latest_chat['timestamp'],
      message_type: latest_chat['message_type'] || 'text',
      status: @message.status,
      outlet_type: 'lounge'
    }
    
    ActionCable.server.broadcast(admin_channel, message_update_data);
  end

  def broadcast_pharmacy_message
    # Get the latest chat from the message thread
    latest_chat = @message.chats.last
    
    # Safety check for latest_chat
    if latest_chat.nil?
      Rails.logger.error "No latest chat found for message #{@message.id}"
      return
    end
    
    # Ensure latest_chat is a hash
    latest_chat = latest_chat.is_a?(String) ? JSON.parse(latest_chat) : latest_chat
    
    # Create standardized broadcast data
    broadcast_data = {
      type: 'new_message',
      id: @message.id,
      chat_id: latest_chat['id'] || SecureRandom.uuid,
      content: latest_chat['content'] || 'No content',
      user: {
        id: @message.sephcocco_user&.id || 'unknown',
        name: @message.sephcocco_user&.name || 'Unknown',
        email: @message.sephcocco_user&.email || '',
        role: @message.sephcocco_user&.sephcocco_user_role&.name || 'user'
      },
      created_at: latest_chat['timestamp'] || Time.current.iso8601,
      message_type: latest_chat['message_type'] || 'text',
      status: @message.status,
      outlet_type: 'pharmacy',
      message_thread_id: @message.id,
      user_id: @message.sephcocco_user_id,
      user_role: @message.sephcocco_user&.sephcocco_user_role&.name || 'user'
    }
    
    # Broadcast to the specific user
    user_channel = "messaging_user_#{@message.sephcocco_user_id}"
    Rails.logger.info "Broadcasting to user channel: #{user_channel}"
    ActionCable.server.broadcast(user_channel, broadcast_data)
    
    # Broadcast to admin channel
    admin_channel = "messaging_admin_pharmacy"
    Rails.logger.info "Broadcasting to admin channel: #{admin_channel}"
    ActionCable.server.broadcast(admin_channel, broadcast_data)
    
    # Also broadcast user thread update to admin
    Messaging::UserThreadService.new('pharmacy').broadcast_user_thread_update(
      @message, 
      latest_chat
    );
    
    # Broadcast message update event
    message_update_data = {
      type: 'message_updated',
      id: @message.id,
      user_id: @message.sephcocco_user_id,
      content: latest_chat['content'],
      created_at: latest_chat['timestamp'],
      message_type: latest_chat['message_type'] || 'text',
      status: @message.status,
      outlet_type: 'pharmacy'
    }
    
    ActionCable.server.broadcast(admin_channel, message_update_data);
  end

  def broadcast_restaurant_message
    # Get the latest chat from the message thread
    latest_chat = @message.chats.last
    
    # Safety check for latest_chat
    if latest_chat.nil?
      Rails.logger.error "No latest chat found for message #{@message.id}"
      return
    end
    
    # Ensure latest_chat is a hash
    latest_chat = latest_chat.is_a?(String) ? JSON.parse(latest_chat) : latest_chat
    
    # Create standardized broadcast data
    broadcast_data = {
      type: 'new_message',
      id: @message.id,
      chat_id: latest_chat['id'] || SecureRandom.uuid,
      content: latest_chat['content'] || 'No content',
      user: {
        id: @message.sephcocco_user&.id || 'unknown',
        name: @message.sephcocco_user&.name || 'Unknown',
        email: @message.sephcocco_user&.email || '',
        role: @message.sephcocco_user&.sephcocco_user_role&.name || 'user'
      },
      created_at: latest_chat['timestamp'] || Time.current.iso8601,
      message_type: latest_chat['message_type'] || 'text',
      status: @message.status,
      outlet_type: 'restaurant',
      message_thread_id: @message.id,
      user_id: @message.sephcocco_user_id,
      user_role: @message.sephcocco_user&.sephcocco_user_role&.name || 'user'
    }
    
    # Broadcast to the specific user
    user_channel = "messaging_user_#{@message.sephcocco_user_id}"
    Rails.logger.info "Broadcasting to user channel: #{user_channel}"
    ActionCable.server.broadcast(user_channel, broadcast_data)
    
    # Broadcast to admin channel
    admin_channel = "messaging_admin_restaurant"
    Rails.logger.info "Broadcasting to admin channel: #{admin_channel}"
    ActionCable.server.broadcast(admin_channel, broadcast_data)
    
    # Also broadcast user thread update to admin
    Messaging::UserThreadService.new('restaurant').broadcast_user_thread_update(
      @message, 
      latest_chat
    );
    
    # Broadcast message update event
    message_update_data = {
      type: 'message_updated',
      id: @message.id,
      user_id: @message.sephcocco_user_id,
      content: latest_chat['content'],
      created_at: latest_chat['timestamp'],
      message_type: latest_chat['message_type'] || 'text',
      status: @message.status,
      outlet_type: 'restaurant'
    }
    
    ActionCable.server.broadcast(admin_channel, message_update_data);
  end

  def broadcast_lounge_message_update
    # Get the latest chat from the message thread
    latest_chat = @message.chats.last
    
    Rails.logger.info "Broadcasting lounge message update: #{@message.id}"
    
    # Safety check for latest_chat
    if latest_chat.nil?
      Rails.logger.error "No latest chat found for message #{@message.id}"
      return
    end
    
    # Ensure latest_chat is a hash
    latest_chat = latest_chat.is_a?(String) ? JSON.parse(latest_chat) : latest_chat
    
    # Create update broadcast data
    update_data = {
      type: 'message_updated',
      id: @message.id,
      user_id: @message.sephcocco_user_id,
      content: latest_chat['content'],
      created_at: latest_chat['timestamp'],
      message_type: latest_chat['message_type'] || 'text',
      status: @message.status,
      outlet_type: 'lounge',
      updated_at: @message.updated_at.iso8601
    }
    
    # Broadcast to the specific user
    user_channel = "messaging_user_#{@message.sephcocco_user_id}"
    Rails.logger.info "Broadcasting update to user channel: #{user_channel}"
    ActionCable.server.broadcast(user_channel, update_data)
    
    # Broadcast to admin channel
    admin_channel = "messaging_admin_lounge"
    Rails.logger.info "Broadcasting update to admin channel: #{admin_channel}"
    ActionCable.server.broadcast(admin_channel, update_data)
  end

  def broadcast_pharmacy_message_update
    # Get the latest chat from the message thread
    latest_chat = @message.chats.last
    
    Rails.logger.info "Broadcasting pharmacy message update: #{@message.id}"
    
    # Safety check for latest_chat
    if latest_chat.nil?
      Rails.logger.error "No latest chat found for message #{@message.id}"
      return
    end
    
    # Ensure latest_chat is a hash
    latest_chat = latest_chat.is_a?(String) ? JSON.parse(latest_chat) : latest_chat
    
    # Create update broadcast data
    update_data = {
      type: 'message_updated',
      id: @message.id,
      user_id: @message.sephcocco_user_id,
      content: latest_chat['content'],
      created_at: latest_chat['timestamp'],
      message_type: latest_chat['message_type'] || 'text',
      status: @message.status,
      outlet_type: 'pharmacy',
      updated_at: @message.updated_at.iso8601
    }
    
    # Broadcast to the specific user
    user_channel = "messaging_user_#{@message.sephcocco_user_id}"
    Rails.logger.info "Broadcasting update to user channel: #{user_channel}"
    ActionCable.server.broadcast(user_channel, update_data)
    
    # Broadcast to admin channel
    admin_channel = "messaging_admin_pharmacy"
    Rails.logger.info "Broadcasting update to admin channel: #{admin_channel}"
    ActionCable.server.broadcast(admin_channel, update_data)
  end

  def broadcast_restaurant_message_update
    # Get the latest chat from the message thread
    latest_chat = @message.chats.last
    
    Rails.logger.info "Broadcasting restaurant message update: #{@message.id}"
    
    # Safety check for latest_chat
    if latest_chat.nil?
      Rails.logger.error "No latest chat found for message #{@message.id}"
      return
    end
    
    # Ensure latest_chat is a hash
    latest_chat = latest_chat.is_a?(String) ? JSON.parse(latest_chat) : latest_chat
    
    # Create update broadcast data
    update_data = {
      type: 'message_updated',
      id: @message.id,
      user_id: @message.sephcocco_user_id,
      content: latest_chat['content'],
      created_at: latest_chat['timestamp'],
      message_type: latest_chat['message_type'] || 'text',
      status: @message.status,
      outlet_type: 'restaurant',
      updated_at: @message.updated_at.iso8601
    }
    
    # Broadcast to the specific user
    user_channel = "messaging_user_#{@message.sephcocco_user_id}"
    Rails.logger.info "Broadcasting update to user channel: #{user_channel}"
    ActionCable.server.broadcast(user_channel, update_data)
    
    # Broadcast to admin channel
    admin_channel = "messaging_admin_restaurant"
    Rails.logger.info "Broadcasting update to admin channel: #{admin_channel}"
    ActionCable.server.broadcast(admin_channel, update_data)
  end
end 