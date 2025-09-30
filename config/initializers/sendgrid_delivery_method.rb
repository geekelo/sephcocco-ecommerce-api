# config/initializers/sendgrid_delivery_method.rb
require "sendgrid-ruby"

class SendGridDeliveryMethod
  include SendGrid

  def initialize(values = {})
    settings = values || {}
    @api_key = settings[:api_key] || ENV["SENDGRID_API_KEY"]
  end

  def deliver!(mail)
    from = Email.new(email: mail.from.first)
    subject = mail.subject

    personalization = Personalization.new
    Array(mail.to).each  { |addr| personalization.add_to(Email.new(email: addr)) }
    Array(mail.cc).each  { |addr| personalization.add_cc(Email.new(email: addr)) }
    Array(mail.bcc).each { |addr| personalization.add_bcc(Email.new(email: addr)) }

    content =
      if mail.html_part
        Content.new(type: "text/html", value: mail.html_part.body.to_s)
      elsif mail.text_part
        Content.new(type: "text/plain", value: mail.text_part.body.to_s)
      else
        Content.new(type: "text/plain", value: mail.body.to_s)
      end

    sg_mail = Mail.new
    sg_mail.from = from
    sg_mail.subject = subject
    sg_mail.add_content(content)
    sg_mail.add_personalization(personalization)

    sg = SendGrid::API.new(api_key: @api_key)
    response = sg.client.mail._("send").post(request_body: sg_mail.to_json)

    Rails.logger.info "SendGrid response: #{response.status_code}"
    Rails.logger.debug response.body unless response.status_code.to_i.between?(200, 299)

    response
  end
end

# Register custom delivery method
ActionMailer::Base.add_delivery_method :sendgrid, SendGridDeliveryMethod
ActionMailer::Base.class_attribute :sendgrid_settings, default: {}

# Configure ActionMailer (this runs for all envs; you can guard with Rails.env.production?)
ActionMailer::Base.delivery_method = :sendgrid
ActionMailer::Base.sendgrid_settings = { api_key: ENV["SENDGRID_API_KEY"] }
