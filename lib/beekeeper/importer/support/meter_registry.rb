# Basically a hash that stores all meters created during the import by their buzznid,
# although the buzznid isn't part of our model any more.
module Beekeeper
  class MeterRegistry

    class << self

      def set(buzznid, meter_instance)
        @meters ||= {}
        verify!(buzznid)
        raise "Not a meter instance: #{meter_instance}" unless meter_instance.is_a?(Meter::Base)
        if @meters[buzznid]
          p '-------------------'
          ap @meters[buzznid]
          ap meter_instance
          # FIXME: at least "90005/5" fails here, investigate
          # raise "Meter for #{buzznid} already set, not overwriting: #{@meters[buzznid].attributes}"
        end
        @meters[buzznid] = meter_instance
      end

      def get(buzznid)
        verify!(buzznid)
        @meters ||= {}
        meter = @meters[buzznid]
        # puts "No meter for #{buzznid}" unless meter
        meter
      end

      def verify!(buzznid)
        raise "buzznid '#{buzznid}' unreliable!!" if buzznid !~ /^([0-9])+\/([0-9])+$/
      end

    end

  end
end
