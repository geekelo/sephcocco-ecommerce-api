module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # Get the token from the request
      token = request.params[:token] || request.headers['Authorization']&.split(' ')&.last
      
      Rails.logger.info "ActionCable: Attempting connection with token: #{token ? 'Present' : 'Missing'}"
      
      if token
        begin
          # Decode the JWT token
          decoded_token = JsonWebToken.decode(token)
          
          if decoded_token && decoded_token["sub"]
            user_id = decoded_token["sub"]
            user = SephcoccoUser.find(user_id)
            Rails.logger.info "ActionCable: Successfully authenticated user: #{user.email}"
            user
          else
            Rails.logger.error "ActionCable: Invalid token structure"
            reject_unauthorized_connection
          end
        rescue JWT::DecodeError => e
          Rails.logger.error "ActionCable: JWT decode error: #{e.message}"
          reject_unauthorized_connection
        rescue ActiveRecord::RecordNotFound => e
          Rails.logger.error "ActionCable: User not found: #{e.message}"
          reject_unauthorized_connection
        rescue => e
          Rails.logger.error "ActionCable: Unexpected error: #{e.message}"
          reject_unauthorized_connection
        end
      else
        Rails.logger.error "ActionCable: No token provided"
        reject_unauthorized_connection
      end
    end
  end
end
