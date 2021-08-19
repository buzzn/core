require 'sidekiq/worker'

module Buzzn
  module Workers
    class PowertakerReportWorker

      include Import['services.powertaker_report_service']
      include Sidekiq::Worker

      def perform
        powertaker_report_service.generate_powertaker_report(self.jid)
      end

    end
  end
end