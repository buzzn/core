# Basically a hash that stores all meters created during the import by their buzznid,
# although the buzznid isn't part of our model any more.
module Beekeeper
  class MeterRegistry

    class << self
      def set(buzznid, meter_instance)
        @meters ||= {}
        raise "Not a meter instance: #{meter_instance}" unless meter_instance.is_a?(Meter::Base)
        raise "Meter for #{buzznid} already set, not overwriting: #{@meters[buzznid].attributes}" if @meters[buzznid]
        @meters[buzznid] = meter_instance
      end

      def get(buzznid)
        @meters ||= {}
        meter = @meters[buzznid]
        puts "No meter for #{buzznid}" unless meter
        meter
      end
    end
  end
end
