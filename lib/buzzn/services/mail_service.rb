require_relative '../services'
require_relative '../workers/mail_worker'
require_relative '../mail_error'

require 'net/http'

class Services::MailService

  REQUIRED_MESSAGE_KEYS=[:from, :to, :subject, :text]
  OPTIONAL_MESSAGE_KEYS=[:bcc, :html]

  include Import['config.mail_backend',
                 'config.mailgun_api_key',
                 'config.mailgun_domain',
                 'services.mailgun_service',
                 'services.mail_stdout_service']

  def initialize(**)
    super
    @logger = Buzzn::Logger.new(self)
  end

  def deliver(message = {})
    message = check_message_params(message)

    case mail_backend
    when 'smtp'
      # not implemented yet
      nil
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
