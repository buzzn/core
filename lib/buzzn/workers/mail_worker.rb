require 'sidekiq/worker'

module Buzzn
  module Workers
    class MailWorker

      include Import['services.mail_service']
      include Sidekiq::Worker

      def perform(message = {})
        mail_service.deliver(message)
      end

    end
  end
end
