require 'sidekiq/worker'

module Buzzn
  module Workers
    class ReportWorker

      include Import['services.report_service']
      include Sidekiq::Worker

      def perform(billing_cycle_id)
        report_service.generate_report(billing_cycle_id, self.jid)
      end

    end
  end
end
