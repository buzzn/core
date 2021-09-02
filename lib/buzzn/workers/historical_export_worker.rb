require 'sidekiq/worker'

module Buzzn
  module Workers
    class HistoricalExportWorker

      include Import['services.report_service']
      include Sidekiq::Worker

      def perform(localpool_id)
        report_service.generate_historical_export(localpool_id, self.jid)
      end

    end
  end
end