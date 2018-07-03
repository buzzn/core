require_relative '../services'
require_relative '../workers/mail_worker'
require_relative '../mail_error'

require 'net/http'

class Services::MailService

  REQUIRED_MESSAGE_KEYS=[:from, :to, :subject, :text]
  OPTIONAL_MESSAGE_KEYS=[:bcc, :html]

  include Import['config.mail_backend',
                 'services.mailgun_service']

  def deliver(message = {})
    message = check_message_params(message)

    case mail_backend
    when 'smtp'
      # not implemented yet
      nil
    when 'mailgun'
      api_key = Import.global('config.mailgun_api_key')
      domain = Import.global('config.mailgun_domain')
      mailgun_service.deliver(domain, api_key, message)
    end
  end

  def deliver_later(message = {})
    message = check_message_params(message)
    Buzzn::Workers::MailWorker.perform_async(message)
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
