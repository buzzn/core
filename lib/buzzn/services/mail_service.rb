require_relative '../services'
require_relative '../workers/mail_worker'
require_relative '../mail_error'

require 'net/http'

class Services::MailService

  REQUIRED_MESSAGE_KEYS=[:to, :subject, :text, :from_person_id]
  OPTIONAL_MESSAGE_KEYS=[:bcc, :reply_to, :html, :document_id, :document_name, :document_mime]

  include Import['config.mail_backend',
                 'config.mailgun_api_key',
                 'config.mailgun_domain',
                 'services.mailgun_service',
                 'services.mail_stdout_service',
                 'services.smtp_service']

  def initialize(**)
    super
    @logger = Buzzn::Logger.new(self)
  end

  def deliver(message = {})
    message = check_message_params(message)

    case mail_backend
    when 'smtp'
      smtp_service.deliver(message)

    when 'mailgun'
      if mailgun_api_key == '11111111111111111111111111111111-11111111-11111111'
        @logger.info('development mailgun api_key: using stdout backend')
        mail_stdout_service.deliver(message)
      else
        mailgun_service.deliver(mailgun_domain, mailgun_api_key, message)
      end
    when 'stdout'
      mail_stdout_service.deliver(message)
    end
  end

  def deliver_billing(billing_id, message)
    billing = Billing.find(billing_id)
    deliver(message)
    if billing.status == 'queued'
      billing.status = 'delivered'
      billing.save
    end
  end

  def deliver_test_mail(contact)
    salute = if contact.prefix == 'male'
               "Sehr geehrter Herr #{contact.last_name},"
             elsif contact.prefix == 'female'
               "Sehr geehrte Frau #{contact.last_name},"
             else
               'Verehrter Strohmnehmer/in,'
             end

    message = <<~MSG
      #{salute}

      wenn Sie diese Email lesen können, scheint ihr Mail-Account richtig in der Platform eingetragen zu sein.

      Bitte bestätigen Sie diesen Umstand in dem Sie diesen Link anklicken: http://de.buzzn.net/activate/#{contact.id}

      Energiegeladene Grüße

      Die Platform im Namen von
      #{contact.first_name} #{contact.name}
      #{contact.email_backend_signature}
    MSG

    deliver({text:  message, subject: 'Buzzn Platform test email', to: contact.email, from_person_id: contact.id})
  end

  def deliver_later(message = {})
    message = check_message_params(message)
    Buzzn::Workers::MailWorker.perform_async(message)
  end

  def deliver_billing_later(billing_id, message = {})
    message = check_message_params(message)
    Buzzn::Workers::BillingMailWorker.perform_async(billing_id, message)
  end

  private

  def check_message_params(message)
    filtered = message.symbolize_keys.slice(*(REQUIRED_MESSAGE_KEYS + OPTIONAL_MESSAGE_KEYS))
    REQUIRED_MESSAGE_KEYS.each do |key|
      unless filtered.key?(key)
        raise Buzzn::MailParameterError.new "#{key} is not in the message hash"
      end
    end
    filtered
  end

end
