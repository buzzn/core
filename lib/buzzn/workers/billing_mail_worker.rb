require 'sidekiq/worker'

module Buzzn
  module Workers
    class BillingMailWorker

      include Import['services.mail_service']
      include Sidekiq::Worker

      def perform(billing_id, message = {})
        mail_service.deliver_billing(billing_id, message)
      end

    end
  end
end
