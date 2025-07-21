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
      
      if token
        begin
          # Decode the JWT token
          decoded_token = JsonWebToken.decode(token)
          user_id = decoded_token[:user_id]
          SephcoccoUser.find(user_id)
        rescue JWT::DecodeError, ActiveRecord::RecordNotFound
          reject_unauthorized_connection
        end
      else
        reject_unauthorized_connection
      end
    end
  end
end
