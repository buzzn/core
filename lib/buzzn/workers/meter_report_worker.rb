require 'sidekiq/worker'

module Buzzn
  module Workers
    class MeterReportWorker

      include Import['services.meter_report_service']
      include Sidekiq::Worker

      def perform
        meter_report_service.generate_meter_report(self.jid)
      end

    end
  end
end