module Buzzn

  class DataSource

    # retrieves power data of all registers of group or virtual_register
    # @param resource [Group, Register] a group or register with register.virtual == true. can not be nil.
    # @param mode [:in, :out] can not be nil.
    # @return [Buzzn::DataResultSet] a set of Buzzn::DataResult elements
    def collection(resource, mode)
      raise 'not implemented'
    end

    # retrieves aggregated power data of all registers of group or a
    # single register using the latest readings.
    # @param resource [Group, Register] a group or register with register.virtual == false. can not be nil
    # @param mode [:in, :out] can not be nil.
    # @return Buzzn::DataResult 
    def single_aggregated(resource, mode)
      raise 'not implemented'
    end

    # retrieves aggregated power data of all registers of group or a
    # single register for the given interval
    # @param resource [Group, Register] a group or register with register.virtual == false. can not be nil.
    # @param mode [:in, :out] can not be nil.
    # @param interval [Buzzn::Interval] time interval and its duration (hour, day, month, year). can not be nil
    # @return Buzzn::DataResultSet a set with an array of 'in' Buzzn::DataResult elements and an array of 'out' Buzzn::DataResult elements
    def aggregated(resource, mode, interval)
      raise 'not implemented'
    end

  end
end
