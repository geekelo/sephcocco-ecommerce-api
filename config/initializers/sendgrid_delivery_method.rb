require 'sendgrid-ruby'

class SendGridDeliveryMethod
  include SendGrid

  def initialize(settings)
    @api_key = settings[:api_key] || ENV['SENDGRID_API_KEY']
  end

  def deliver!(mail)
    from = Email.new(email: mail.from.first)
    to = Email.new(email: mail.to.first)
    subject = mail.subject
    
    # Handle both HTML and text content
    if mail.html_part
      # Multipart email with HTML
      content = Content.new(type: 'text/html', value: mail.html_part.body.to_s.html_safe)
    elsif mail.text_part
      # Multipart email with text only
      content = Content.new(type: 'text/plain', value: mail.text_part.body.to_s)
    else
      # Single part email - determine type by content
      body_content = mail.body.to_s
      if body_content.include?('<html') || body_content.include?('<div') || body_content.include?('<p>')
        content = Content.new(type: 'text/html', value: body_content.html_safe)
      else
        content = Content.new(type: 'text/plain', value: body_content)
      end
    end
    
    sg_mail = Mail.new(from, subject, to, content)
    
    # Add CC and BCC if present
    if mail.cc.present?
      sg_mail.add_cc(Email.new(email: mail.cc.first))
    end
    
    if mail.bcc.present?
      sg_mail.add_bcc(Email.new(email: mail.bcc.first))
    end

    sg = SendGrid::API.new(api_key: @api_key)
    response = sg.client.mail._('send').post(request_body: sg_mail.to_json)
    
    Rails.logger.info "SendGrid email sent: #{response.status_code}"
    Rails.logger.error "SendGrid email failed: #{response.body}" unless response.status_code.to_i.between?(200, 299)
    
    response
  end
end

# Register the custom delivery method
ActionMailer::Base.add_delivery_method :sendgrid, SendGridDeliveryMethod

# Add the sendgrid_settings method to ActionMailer
class ActionMailer::Base
  class_attribute :sendgrid_settings, default: {}
  
  def self.sendgrid_settings=(settings)
    @sendgrid_settings = settings
  end
  
  def self.sendgrid_settings
    @sendgrid_settings || {}
  end
end
