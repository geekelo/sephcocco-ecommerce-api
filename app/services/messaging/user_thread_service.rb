class Messaging::UserThreadService
  def initialize(outlet_type)
    @outlet_type = outlet_type
  end

  def broadcast_new_user_thread(user, message_thread, latest_chat)
    user_thread_data = {
      type: 'new_user_thread',
      user_thread: {
        user_id: message_thread.sephcocco_user_id,
        user_name: user.name,
        user_email: user.email,
        last_activity: message_thread.created_at,
        message_count: 1,
        status: message_thread.status,
        last_message: latest_chat['content']
      }
    }
    
    ActionCable.server.broadcast(
      "messaging_admin_#{@outlet_type}",
      user_thread_data
    )
  end

  def broadcast_user_thread_update(message_thread, latest_chat)
    user_thread_update = {
      type: 'user_thread_updated',
      user_id: message_thread.sephcocco_user_id,
      last_message: latest_chat['content'],
      last_activity: latest_chat['timestamp'],
      message_count: message_thread.chats.length
    }
    
    ActionCable.server.broadcast(
      "messaging_admin_#{@outlet_type}",
      user_thread_update
    )
  end

  def get_user_threads_for_admin(outlet_type, status: nil, page: 1, per_page: 20)
    message_class = case outlet_type
                   when 'lounge'
                     Lounge::SephcoccoLoungeMessage
                   when 'pharmacy'
                     Pharmacy::SephcoccoPharmacyMessage
                   when 'restaurant'
                     Restaurant::SephcoccoRestaurantMessage
                   end

    return [] unless message_class

    # Get all unique users who have message threads
    user_threads = message_class.includes(:sephcocco_user)
                                .group(:sephcocco_user_id)
                                .select('sephcocco_user_id, MAX(created_at) as last_activity, COUNT(*) as message_count')
                                .order('last_activity DESC')

    # Apply status filter
    user_threads = user_threads.where(status: status) if status.present?

    # Apply pagination
    user_threads = user_threads.page(page).per(per_page)

    # Get detailed thread information for each user
    user_threads.map do |thread_info|
      user = SephcoccoUser.find(thread_info.sephcocco_user_id)
      latest_message = message_class.where(sephcocco_user_id: thread_info.sephcocco_user_id)
                                   .order(created_at: :desc)
                                   .first

      # Extract last message content from chats JSONB array
      last_message_content = nil
      if latest_message&.chats&.present?
        chats_array = latest_message.chats.is_a?(String) ? JSON.parse(latest_message.chats) : latest_message.chats
        last_message_content = chats_array.last&.dig('content') if chats_array.any?
      end

      {
        user_id: thread_info.sephcocco_user_id,
        user_name: user.name,
        user_email: user.email,
        last_activity: thread_info.last_activity,
        message_count: thread_info.message_count,
        status: latest_message&.status || 'open',
        last_message: last_message_content,
        unread_count: message_class.where(sephcocco_user_id: thread_info.sephcocco_user_id, status: 'unread').count
      }
    end
  end
end 