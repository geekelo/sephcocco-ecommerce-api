# app/services/r2_upload_service.rb
class R2UploadService
  class ConfigurationError < StandardError; end

  def initialize
    validate_credentials!
    @client = Aws::S3::Client.new(
      region: 'auto',
      endpoint: "https://#{ENV['CLOUDFLARE_ACCOUNT_ID']}.r2.cloudflarestorage.com",
      access_key_id: ENV['CLOUDFLARE_R2_ACCESS_KEY_ID'],
      secret_access_key: ENV['CLOUDFLARE_R2_SECRET_ACCESS_KEY']
    )
  end

  def upload_file(file)
    validate_file!(file)
    key = generate_unique_key(file.original_filename)
    
    begin
      @client.put_object(
        bucket: ENV['CLOUDFLARE_R2_BUCKET'],
        key: key,
        body: file.read,
        content_type: file.content_type
      )

      {
        key: key,
        public_url: "https://#{ENV['CLOUDFLARE_R2_BUCKET']}.r2.cloudflarestorage.com/#{key}"
      }
    rescue Aws::S3::Errors::ServiceError => e
      Rails.logger.error("R2 Upload Error: #{e.message}")
      raise ConfigurationError, "Failed to upload file to R2: #{e.message}"
    end
  end

  private

  def validate_credentials!
    required_vars = [
      'CLOUDFLARE_ACCOUNT_ID',
      'CLOUDFLARE_R2_ACCESS_KEY_ID',
      'CLOUDFLARE_R2_SECRET_ACCESS_KEY',
      'CLOUDFLARE_R2_BUCKET'
    ]

    missing_vars = required_vars.select { |var| ENV[var].blank? }
    
    if missing_vars.any?
      raise ConfigurationError, "Missing required environment variables: #{missing_vars.join(', ')}"
    end
  end

  def validate_file!(file)
    unless file.respond_to?(:read) && file.respond_to?(:content_type)
      raise ArgumentError, "Invalid file object provided"
    end

    unless file.content_type.start_with?('image/')
      raise ArgumentError, "File must be an image"
    end

    # Check file size (5MB limit)
    if file.size > 5.megabytes
      raise ArgumentError, "File size must be less than 5MB"
    end
  end

  def generate_unique_key(original_filename)
    extension = File.extname(original_filename)
    "#{SecureRandom.uuid}#{extension}"
  end
end
