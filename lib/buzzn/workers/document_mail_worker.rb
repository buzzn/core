require 'sidekiq/worker'

module Buzzn
  module Workers
    class DocumentMailWorker

      include Import['services.mail_service']
      include Sidekiq::Worker

      def perform(document_id, message = {})
        mail_service.deliver_document(document_id, message)
      end

    end
  end
end
