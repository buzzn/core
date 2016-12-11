module Buzzn

  class DataSource

    # retrieves power data of all registers of group or virtual_register
    # @param resource [Group, Register] a group or register with register.virtual == true
    # @param mode [:in, :out]
    # @result [Buzzn::DataResultSet] a set of Buzzn::DataResult elements
    def collection(resource, mode)
      raise 'not implemented'
    end

    # retrieves aggregated power data of all registers of group or a
    # sigle register
    # @param resource [Group, Register] a group or register with register.virtual == false
    # @param mode [:in, :out]
    # @param interval [Buzzn::Interval] time interval and its duration (hour, day, month, year) or nil
    # @result [Buzzn::DataResultSet, Buzzn::DataResult] if interval is nil the it is a Buzzn::DataResult otherwise it is a set of Buzzn::DataResult elements
    def aggregated(register_or_group, mode, interval = nil)
      raise 'not implemented'
    end

  end
end
