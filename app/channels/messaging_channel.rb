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
    Rails.logger.info "📨 Received WebSocket data: #{data.inspect}"
    Rails.logger.info "📨 Data keys: #{data.keys}"
    Rails.logger.info "📨 Action: #{data['action']}"
    
    # Check if this is a request for initial threads
    if data['action'] == 'request_initial_threads'
      Rails.logger.info "📋 Processing request_initial_threads request"
      request_initial_threads(data)
      return
    end
    
    # Check if this is an update message request
    if data['action'] == 'update_message'
      Rails.logger.info "📝 Processing update_message request"
      update_message(data)
      return
    end
    
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
          
          # Validate that the user exists
          begin
            target_user = SephcoccoUser.find(user_id)
            Rails.logger.info "✅ Found target user: #{target_user.id} (#{target_user.name})"
          rescue ActiveRecord::RecordNotFound
            Rails.logger.error "❌ User not found: #{user_id}"
            ActionCable.server.broadcast(
              "messaging_admin_#{outlet_type}",
              { error: "User not found: #{user_id}" }
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

  def request_initial_threads(data)
    Rails.logger.info "🔍 Admin requesting initial threads for outlet: #{data['outlet_type']}"
    Rails.logger.info "🔍 Current user: #{current_user&.id}"
    Rails.logger.info "🔍 User role: #{current_user&.sephcocco_user_role&.name}"
    Rails.logger.info "🔍 Data received: #{data.inspect}"
    
    return unless current_user&.sephcocco_user_role&.name == "admin"
    
    outlet_type = data['outlet_type']
    Rails.logger.info "🔍 Processing outlet type: #{outlet_type}"
    
    # Test if the model class exists
    message_class = case outlet_type
                   when 'lounge'
                     begin
                       Lounge::SephcoccoLoungeMessage
                     rescue NameError => e
                       Rails.logger.error "❌ Lounge::SephcoccoLoungeMessage model not found: #{e.message}"
                       nil
                     end
                   when 'pharmacy'
                     begin
                       Pharmacy::SephcoccoPharmacyMessage
                     rescue NameError => e
                       Rails.logger.error "❌ Pharmacy::SephcoccoPharmacyMessage model not found: #{e.message}"
                       nil
                     end
                   when 'restaurant'
                     begin
                       Restaurant::SephcoccoRestaurantMessage
                     rescue NameError => e
                       Rails.logger.error "❌ Restaurant::SephcoccoRestaurantMessage model not found: #{e.message}"
                       nil
                     end
                   end
    
    Rails.logger.info "🔍 Message class: #{message_class}"
    
    if message_class
      # Get all open threads for this outlet
      begin
        # Test database connection
        Rails.logger.info "🔍 Testing database connection..."
        ActiveRecord::Base.connection.execute("SELECT 1")
        Rails.logger.info "✅ Database connection successful"
        
        # Check if table exists
        table_name = message_class.table_name
        Rails.logger.info "🔍 Checking if table exists: #{table_name}"
        table_exists = ActiveRecord::Base.connection.table_exists?(table_name)
        Rails.logger.info "🔍 Table exists: #{table_exists}"
        
        if !table_exists
          Rails.logger.error "❌ Table #{table_name} does not exist"
          ActionCable.server.broadcast(
            "messaging_admin_#{outlet_type}",
            {
              type: 'user_threads_response',
              threads: [],
              error: "Table #{table_name} does not exist"
            }
          )
          return
        end
        
        threads = message_class.where(status: 'open').includes(:sephcocco_user)
        
        Rails.logger.info "🔍 Found #{threads.count} open threads for #{outlet_type}"
        Rails.logger.info "🔍 Threads: #{threads.map(&:id)}"
        
        # Also check total threads regardless of status
        total_threads = message_class.count
        Rails.logger.info "🔍 Total threads in database: #{total_threads}"
        
        # Check all tables for any message data
        Rails.logger.info "🔍 Checking all message tables for data..."
        ['lounge_sephcocco_lounge_messages', 'pharmacy_sephcocco_pharmacy_messages', 'restaurant_sephcocco_restaurant_messages'].each do |table|
          if ActiveRecord::Base.connection.table_exists?(table)
            count = ActiveRecord::Base.connection.execute("SELECT COUNT(*) FROM #{table}").first[0]
            Rails.logger.info "🔍 Table #{table}: #{count} records"
          else
            Rails.logger.info "🔍 Table #{table}: does not exist"
          end
        end
        
        # If no threads exist, create a test thread for demonstration
        if total_threads == 0
          Rails.logger.info "🧪 No threads found, creating a test thread for demonstration..."
          begin
            # Create a test user if needed
            test_user = SephcoccoUser.find_or_create_by(email: 'test@example.com') do |user|
              user.name = 'Test User'
              user.password = 'password123'
              user.password_confirmation = 'password123'
            end
            
            # Create a test thread
            test_thread = message_class.create!(
              sephcocco_user_id: test_user.id,
              status: 'open',
              chats: [
                {
                  id: SecureRandom.uuid,
                  content: 'Hello! This is a test message.',
                  message_type: 'text',
                  user_id: test_user.id,
                  user_name: test_user.name,
                  user_email: test_user.email,
                  user_role: 'user',
                  timestamp: Time.current.iso8601
                }
              ]
            )
            
            Rails.logger.info "🧪 Created test thread: #{test_thread.id}"
            threads = [test_thread]
            total_threads = 1
          rescue => e
            Rails.logger.error "❌ Failed to create test thread: #{e.message}"
          end
        end
        
        # Transform threads to frontend format
        thread_data = threads.map do |thread|
          last_chat = thread.chats.last
          Rails.logger.info "🔍 Processing thread #{thread.id}: user_id=#{thread.sephcocco_user_id}, chats_count=#{thread.chats.count}"
          
          {
            user_id: thread.sephcocco_user_id,
            user_name: thread.sephcocco_user&.name || 'Unknown User',
            user_email: thread.sephcocco_user&.email || '',
            status: thread.status,
            created_at: thread.created_at&.iso8601,
            updated_at: thread.updated_at&.iso8601,
            last_message: last_chat&.dig('content') || 'No messages yet',
            message_count: thread.chats.count,
            unread_count: thread.chats.count { |chat| chat['status'] == 'unread' },
            messages: thread.chats.map do |chat|
              {
                id: chat['id'],
                content: chat['content'],
                message_type: chat['message_type'] || 'text',
                user_id: chat['user_id'],
                user_name: chat['user_name'],
                user_email: chat['user_email'],
                user_role: chat['user_role'],
                timestamp: chat['timestamp']
              }
            end
          }
        end
        
        Rails.logger.info "🔍 Prepared thread data: #{thread_data.length} threads"
        
        # Send initial threads to admin
        admin_channel = "messaging_admin_#{outlet_type}"
        Rails.logger.info "🔍 Broadcasting to admin channel: #{admin_channel}"
        
        ActionCable.server.broadcast(
          admin_channel,
          {
            type: 'user_threads_response',
            threads: thread_data
          }
        )
        
        Rails.logger.info "✅ Sent #{thread_data.count} initial threads to admin"
        
      rescue => e
        Rails.logger.error "❌ Error processing threads: #{e.message}"
        Rails.logger.error "❌ Backtrace: #{e.backtrace.first(5)}"
        
        # Send empty response to prevent frontend from hanging
        ActionCable.server.broadcast(
          "messaging_admin_#{outlet_type}",
          {
            type: 'user_threads_response',
            threads: [],
            error: "Error processing threads: #{e.message}"
          }
        )
      end
    else
      Rails.logger.error "❌ No message class found for outlet type: #{outlet_type}"
      
      # Send empty response to prevent frontend from hanging
      ActionCable.server.broadcast(
        "messaging_admin_#{outlet_type}",
        {
          type: 'user_threads_response',
          threads: [],
          error: "No message class found for outlet type: #{outlet_type}"
        }
      )
    end
  end

  def update_message(data)
    Rails.logger.info "📝 Admin updating message for outlet: #{data['outlet_type']}"
    Rails.logger.info "📝 Current user: #{current_user&.id}"
    Rails.logger.info "📝 User role: #{current_user&.sephcocco_user_role&.name}"
    Rails.logger.info "📝 Data received: #{data.inspect}"
    
    return unless current_user&.sephcocco_user_role&.name == "admin"
    
    outlet_type = data['outlet_type']
    message_id = data['message_id']
    update_data = data['update_data'] || {}
    
    Rails.logger.info "📝 Processing message update: message_id=#{message_id}, outlet_type=#{outlet_type}"
    
    # Get the message class
    message_class = case outlet_type
                   when 'lounge'
                     Lounge::SephcoccoLoungeMessage
                   when 'pharmacy'
                     Pharmacy::SephcoccoPharmacyMessage
                   when 'restaurant'
                     Restaurant::SephcoccoRestaurantMessage
                   end
    
    if message_class && message_id
      begin
        # Find the message
        message = message_class.find(message_id)
        Rails.logger.info "📝 Found message: #{message.id}"
        
        # Update the message based on update_data
        if update_data['status'].present?
          message.update!(status: update_data['status'])
          Rails.logger.info "📝 Updated status to: #{update_data['status']}"
        end
        
        if update_data['chat'].present?
          # Add new chat to existing chats
          new_chat = {
            id: SecureRandom.uuid,
            content: update_data['chat']['content'],
            message_type: update_data['chat']['message_type'] || 'text',
            user_id: current_user.id,
            user_name: current_user.name,
            user_email: current_user.email,
            user_role: current_user.sephcocco_user_role.name,
            timestamp: Time.current.iso8601
          }
          
          message.chats << new_chat
          message.save!
          Rails.logger.info "📝 Added new chat to message"
        end
        
        # Broadcast the update to all connected clients
        Messaging::BroadcastService.new(message, outlet_type).call
        
        Rails.logger.info "✅ Message update completed and broadcasted"
        
        # Send confirmation back to the sender
        ActionCable.server.broadcast(
          "messaging_admin_#{outlet_type}",
          {
            type: 'message_update_confirmation',
            message_id: message_id,
            status: 'success',
            updated_at: message.updated_at.iso8601
          }
        )
        
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error "❌ Message not found: #{e.message}"
        ActionCable.server.broadcast(
          "messaging_admin_#{outlet_type}",
          {
            type: 'message_update_confirmation',
            message_id: message_id,
            status: 'error',
            error: 'Message not found'
          }
        )
      rescue => e
        Rails.logger.error "❌ Error updating message: #{e.message}"
        ActionCable.server.broadcast(
          "messaging_admin_#{outlet_type}",
          {
            type: 'message_update_confirmation',
            message_id: message_id,
            status: 'error',
            error: e.message
          }
        )
      end
    else
      Rails.logger.error "❌ Invalid message class or message_id"
      ActionCable.server.broadcast(
        "messaging_admin_#{outlet_type}",
        {
          type: 'message_update_confirmation',
          message_id: message_id,
          status: 'error',
          error: 'Invalid message class or message_id'
        }
      )
    end
  end
end
