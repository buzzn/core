module Buzzn
  module Workers
    class MailWorker

      include Sidekiq::Worker

      def perform(message = {})
        mail_service = Import.global('services.mail_service')
        mail_service.deliver(message)
      end

    end
  end
end
