class MessagingChannel < ApplicationCable::Channel
  def subscribed
    # Subscribe to a room based on user or outlet
    if current_user
      if current_user.sephcocco_user_role.name == "admin"
        # Admins can subscribe to all messages or specific outlet messages
        outlet_id = params[:outlet_id]
        if outlet_id
          stream_from "messaging_#{outlet_id}"
        else
          stream_from "messaging_all"
        end
      else
        # Regular users subscribe to their personal messages
        stream_from "messaging_user_#{current_user.id}"
      end
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    # Handle incoming messages from clients
    message_data = data['message']
    outlet_type = data['outlet_type'] # 'lounge', 'pharmacy', 'restaurant'
    product_id = data['product_id'] # Optional product reference
    
    # Create the message in the database
    message_class = case outlet_type
                   when 'lounge'
                     Lounge::SephcoccoLoungeMessage
                   when 'pharmacy'
                     Pharmacy::SephcoccoPharmacyMessage
                   when 'restaurant'
                     Restaurant::SephcoccoRestaurantMessage
                   end

    if message_class && current_user
      # Find existing message thread or create new one
      message_thread = message_class.find_or_create_by(
        sephcocco_user_id: current_user.id,
        status: 'open'
      ) do |thread|
        # Set product reference if provided
        if product_id
          product_class = case outlet_type
                         when 'lounge'
                           Lounge::SephcoccoLoungeProduct
                         when 'pharmacy'
                           Pharmacy::SephcoccoPharmacyProduct
                         when 'restaurant'
                           Restaurant::SephcoccoRestaurantProduct
                         end
          thread.send("#{product_class.table_name.singularize}=", product_class.find(product_id))
        end
      end

      # Add new chat to the existing chats array
      new_chat = {
        id: SecureRandom.uuid,
        content: message_data['content'],
        message_type: message_data['message_type'] || 'text',
        user_id: current_user.id,
        user_name: current_user.name,
        user_email: current_user.email,
        timestamp: Time.current.iso8601
      }

      message_thread.chats << new_chat
      message_thread.save!

      # Broadcast the message to relevant subscribers
      broadcast_data = {
        id: message_thread.id,
        chat_id: new_chat[:id],
        content: new_chat[:content],
        user: {
          id: current_user.id,
          name: current_user.name,
          email: current_user.email
        },
        created_at: new_chat[:timestamp],
        message_type: new_chat[:message_type],
        status: message_thread.status
      }

      if current_user.sephcocco_user_role.name == "admin"
        ActionCable.server.broadcast(
          "messaging_#{outlet_type}",
          broadcast_data
        )
      else
        # For regular users, broadcast to their personal channel
        ActionCable.server.broadcast(
          "messaging_user_#{current_user.id}",
          broadcast_data
        )
      end
    end
  end
end 