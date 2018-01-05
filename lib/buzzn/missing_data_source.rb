require_relative 'data_source'

module Buzzn

  # temporary workaround class until we have all the datasources for all our registers
  class MissingDataSource < DataSource

    NAME = :missing

    def bubbles(group)
      nil
    end

    def daily_charts(group)
      nil
    end

    def single_aggregated(resource, mode)
      DataResult.new(Time.current.to_f, 0, resource.id, mode) if resource.is_a?(Register::Base) && resource.data_source == :missing
    end

    def aggregated(resource, mode, interval)
      nil
    end
  end
end
