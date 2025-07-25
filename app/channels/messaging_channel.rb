class MessagingChannel < ApplicationCable::Channel
  def subscribed
    # Subscribe to a room based on user or outlet
    if current_user
      if current_user.sephcocco_user_role.name == "admin"
        # Admins subscribe to all user channels for their outlet type
        outlet_type = params[:outlet_type] # 'lounge', 'pharmacy', 'restaurant'
        if outlet_type
          # Admin subscribes to all user channels for this outlet
          stream_from "messaging_admin_#{outlet_type}"
          # Also subscribe to individual user channels to receive messages
          stream_from "messaging_admin_#{outlet_type}_users"
        else
          stream_from "messaging_admin_all"
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
    message_id = data['message_id'] # Optional: for admin responding to existing thread
    
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
      # Find or create message thread
      if message_id.present?
        # Admin responding to existing thread
        message_thread = message_class.find(message_id)
      else
        # User creating new thread or admin creating new thread
        if current_user.sephcocco_user_role.name == "admin"
          # Admin creating new thread - need user_id
          user_id = data['user_id']
          if user_id.blank?
            ActionCable.server.broadcast(
              "messaging_admin_#{outlet_type}",
              { error: "user_id is required for admin messages" }
            )
            return
          end
          message_thread = message_class.find_or_create_by(
            sephcocco_user_id: user_id,
            status: 'open'
          ) do |thread|
            # Set product reference if provided
            if product_id.present?
              product_class = case outlet_type
                             when 'lounge'
                               Lounge::SephcoccoLoungeProduct
                             when 'pharmacy'
                               Pharmacy::SephcoccoPharmacyProduct
                             when 'restaurant'
                               Restaurant::SephcoccoRestaurantProduct
                             end
              begin
                product = product_class.find(product_id)
                thread.send("#{product_class.table_name.singularize}=", product)
              rescue ActiveRecord::RecordNotFound
                Rails.logger.warn "Product with ID #{product_id} not found for #{outlet_type}"
              end
            end
          end
        else
          # User creating new thread
          message_thread = message_class.find_or_create_by(
            sephcocco_user_id: current_user.id,
            status: 'open'
          ) do |thread|
            # Set product reference if provided
            if product_id.present?
              product_class = case outlet_type
                             when 'lounge'
                               Lounge::SephcoccoLoungeProduct
                             when 'pharmacy'
                               Pharmacy::SephcoccoPharmacyProduct
                             when 'restaurant'
                               Restaurant::SephcoccoRestaurantProduct
                             end
              begin
                product = product_class.find(product_id)
                thread.send("#{product_class.table_name.singularize}=", product)
              rescue ActiveRecord::RecordNotFound
                Rails.logger.warn "Product with ID #{product_id} not found for #{outlet_type}"
              end
            end
          end
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
        user_role: current_user.sephcocco_user_role.name,
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
          email: current_user.email,
          role: current_user.sephcocco_user_role.name
        },
        created_at: new_chat[:timestamp],
        message_type: new_chat[:message_type],
        status: message_thread.status,
        outlet_type: outlet_type,
        message_thread_id: message_thread.id,
        user_id: message_thread.sephcocco_user_id
      }

      if current_user.sephcocco_user_role.name == "admin"
        # Admin message - broadcast to the specific user
        ActionCable.server.broadcast(
          "messaging_user_#{message_thread.sephcocco_user_id}",
          broadcast_data
        )
        
        # Also broadcast to admin channel for admin UI updates
        ActionCable.server.broadcast(
          "messaging_admin_#{outlet_type}",
          broadcast_data
        )
      else
        # User message - broadcast to the user
        ActionCable.server.broadcast(
          "messaging_user_#{current_user.id}",
          broadcast_data
        )
        
        # Broadcast to admin channel with user-specific data
        # This allows admins to see which user sent the message
        admin_broadcast_data = broadcast_data.merge({
          action: 'new_user_message',
          user_thread_id: message_thread.id,
          user_name: current_user.name,
          user_email: current_user.email
        })
        
        ActionCable.server.broadcast(
          "messaging_admin_#{outlet_type}",
          admin_broadcast_data
        )
      end
    end
  end
end 