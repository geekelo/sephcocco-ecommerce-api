require 'net/http'
require 'json'

class MailtrapDeliveryMethod
  attr_accessor :settings

  def initialize(settings = {})
    @settings = settings
  end

  def deliver!(mail)
    # Debug logging
    Rails.logger.info "MailtrapDeliveryMethod - @settings: #{@settings.inspect}"
    Rails.logger.info "MailtrapDeliveryMethod - ActionMailer::Base.mailtrap_settings: #{ActionMailer::Base.mailtrap_settings.inspect}"
    
    # Support both api_key and api_token for flexibility
    # Also check ActionMailer's mailtrap_settings if not passed directly
    api_token = @settings[:api_token] || @settings[:api_key] ||
                ActionMailer::Base.mailtrap_settings[:api_token] ||
                ActionMailer::Base.mailtrap_settings[:api_key]
    
    Rails.logger.info "MailtrapDeliveryMethod - api_token: #{api_token ? api_token[0..10] + '...' : 'nil'}"
    
    raise "Mailtrap API token is required" if api_token.nil? || api_token.empty?

    # Get settings from either direct settings or ActionMailer config
    sandbox = @settings[:sandbox] || ActionMailer::Base.mailtrap_settings[:sandbox]
    inbox_id = @settings[:inbox_id] || ActionMailer::Base.mailtrap_settings[:inbox_id]
    
    # Determine if we're using sandbox or production
    endpoint = if sandbox
      "https://sandbox.api.mailtrap.io/api/send/#{inbox_id}"
    else
      "https://send.api.mailtrap.io/api/send"
    end

    uri = URI(endpoint)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path)
    request['Api-Token'] = api_token
    request['Content-Type'] = 'application/json'

    # Build the email payload
    payload = build_payload(mail)
    request.body = payload.to_json

    Rails.logger.info "Sending email via Mailtrap API to: #{mail.to.join(', ')}"
    
    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      error_message = "Mailtrap API error: #{response.code} - #{response.body}"
      Rails.logger.error error_message
      raise error_message
    end

    Rails.logger.info "Email sent successfully via Mailtrap API"
    response
  end

  private

  def build_payload(mail)
    payload = {
      from: {
        email: mail.from.first,
        name: extract_name_from_email(mail[:from])
      },
      to: mail.to.map { |email| { email: email } },
      subject: mail.subject
    }

    # Add CC if present
    payload[:cc] = mail.cc.map { |email| { email: email } } if mail.cc.present?

    # Add BCC if present
    payload[:bcc] = mail.bcc.map { |email| { email: email } } if mail.bcc.present?

    # Add reply-to if present
    if mail.reply_to.present?
      payload[:reply_to] = {
        email: mail.reply_to.first,
        name: extract_name_from_email(mail[:reply_to])
      }
    end

    # Handle multipart emails (HTML and text)
    if mail.multipart?
      html_part = mail.html_part
      text_part = mail.text_part
      
      payload[:html] = html_part.body.decoded if html_part
      payload[:text] = text_part.body.decoded if text_part
    else
      # Single part email
      if mail.content_type.include?('text/html')
        payload[:html] = mail.body.decoded
      else
        payload[:text] = mail.body.decoded
      end
    end

    # Add attachments if present
    if mail.attachments.present?
      payload[:attachments] = mail.attachments.map do |attachment|
        {
          content: Base64.strict_encode64(attachment.body.decoded),
          filename: attachment.filename,
          type: attachment.content_type,
          disposition: attachment.content_disposition || 'attachment'
        }
      end
    end

    # Add custom headers if present
    if mail.header.fields.any? { |field| field.name.start_with?('X-') }
      payload[:headers] = {}
      mail.header.fields.each do |field|
        if field.name.start_with?('X-')
          payload[:headers][field.name] = field.value
        end
      end
    end

    # Add category for production API
    payload[:category] = @settings[:category] if @settings[:category].present?

    payload
  end

  def extract_name_from_email(address_field)
    return nil unless address_field
    
    if address_field.respond_to?(:display_names)
      address_field.display_names.first
    elsif address_field.respond_to?(:decoded)
      # Try to extract name from "Name <email@example.com>" format
      decoded = address_field.decoded
      match = decoded.match(/^(.+?)\s*<.+>$/)
      match ? match[1].strip.gsub(/["']/, '') : nil
    end
  end
end
