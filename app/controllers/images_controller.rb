class ImagesController < ApplicationController
  def show
    # Get the image key from the URL
    key = params[:key]
    
    # Create a temporary file to store the image
    temp_file = Tempfile.new(['image', File.extname(key)])
    
    begin
      # Download the image from R2
      client = Aws::S3::Client.new(
        endpoint: ENV['CLOUDFLARE_R2_ENDPOINT'],
        region: 'auto',
        access_key_id: ENV['CLOUDFLARE_R2_ACCESS_KEY_ID'],
        secret_access_key: ENV['CLOUDFLARE_R2_SECRET_ACCESS_KEY']
      )
      
      client.get_object(
        bucket: ENV['CLOUDFLARE_R2_BUCKET'],
        key: key,
        response_target: temp_file.path
      )
      
      # Set the content type based on the file extension
      content_type = case File.extname(key).downcase
                    when '.jpg', '.jpeg'
                      'image/jpeg'
                    when '.png'
                      'image/png'
                    when '.gif'
                      'image/gif'
                    when '.webp'
                      'image/webp'
                    else
                      'application/octet-stream'
                    end
      
      # Set cache headers
      response.headers['Cache-Control'] = 'public, max-age=31536000' # 1 year
      response.headers['ETag'] = Digest::MD5.file(temp_file.path).hexdigest
      
      # Send the file
      send_file temp_file.path,
                type: content_type,
                disposition: 'inline'
    ensure
      # Clean up the temporary file
      temp_file.close
      temp_file.unlink
    end
  end
end 