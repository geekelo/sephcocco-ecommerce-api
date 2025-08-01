class MessagingChannel < ApplicationCable::Channel
  def subscribed
    # Subscribe to a room based on user or outlet
    Rails.logger.info "MessagingChannel#subscribed called"
    Rails.logger.info "Current user: #{current_user&.id}"
    Rails.logger.info "User role: #{current_user&.sephcocco_user_role&.name}"
    Rails.logger.info "Outlet type param: #{params[:outlet_type]}"
    
    if current_user
      if current_user.sephcocco_user_role.name == "admin"
        # Admins subscribe to all user channels for their outlet type
        outlet_type = params[:outlet_type] # 'lounge', 'pharmacy', 'restaurant'
        Rails.logger.info "Admin user subscribing to outlet: #{outlet_type}"
        
        if outlet_type
          # Admin subscribes to all user channels for this outlet
          admin_channel = "messaging_admin_#{outlet_type}"
          Rails.logger.info "Admin subscribing to channel: #{admin_channel}"
          stream_from admin_channel
          
          # Also subscribe to individual user channels to receive messages
          admin_users_channel = "messaging_admin_#{outlet_type}_users"
          Rails.logger.info "Admin subscribing to users channel: #{admin_users_channel}"
          stream_from admin_users_channel
        else
          Rails.logger.info "Admin subscribing to all channels"
          stream_from "messaging_admin_all"
        end
      else
        # Regular users subscribe to their personal messages
        user_channel = "messaging_user_#{current_user.id}"
        Rails.logger.info "Regular user subscribing to channel: #{user_channel}"
        stream_from user_channel
      end
    else
      Rails.logger.warn "No current_user found in MessagingChannel#subscribed"
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    # Handle incoming messages from clients
    Rails.logger.info "Received WebSocket data: #{data.inspect}"
    
    # Support both formats: data['message'] and direct data
    message_data = data['message'] || data
    outlet_type = data['outlet_type'] # 'lounge', 'pharmacy', 'restaurant'
    product_id = data['product_id'] # Optional product reference
    message_id = data['message_id'] # Optional: for admin responding to existing thread
    
    Rails.logger.info "Processed data - message_data: #{message_data.inspect}, outlet_type: #{outlet_type}"
    
    # Create the message in the database
    message_class = case outlet_type
                   when 'lounge'
                     Lounge::SephcoccoLoungeMessage
                   when 'pharmacy'
                     Pharmacy::SephcoccoPharmacyMessage
                   when 'restaurant'
                     Restaurant::SephcoccoRestaurantMessage
                   end

    if message_class && current_user && message_data && message_data['content'].present?
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

      # Use the broadcast service to ensure consistent broadcasting
      Messaging::BroadcastService.new(message_thread, outlet_type).call
      
      # Also broadcast new user thread to admin if this is a new thread
      if current_user.sephcocco_user_role.name != "admin"
        # This is a user creating a new thread, notify admin
        Messaging::UserThreadService.new(outlet_type).broadcast_new_user_thread(
          current_user, 
          message_thread, 
          new_chat
        )
      end
    end
  end
end 