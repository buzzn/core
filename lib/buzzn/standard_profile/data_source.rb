module Buzzn::StandardProfile
  class DataSource < Buzzn::DataSource

    IN_PROFILES = ['slp']
    OUT_PROFILES = ['sep_bhkw', 'sep_pv']

    def initialize(facade = Facade.new)
      @facade = facade
    end

    # single_value
    def single_aggregated(resource, mode)
      registers_hash = sort_resource(resource)
      data_results = registers_hash_to_data_results(registers_hash, mode, ['power'], Time.current)
      data_results ? data_results.first : nil
    end

    # value_list
    def collection(resource, mode)
      registers_hash = sort_resource(resource)
      data_results = registers_hash_to_data_results(registers_hash, mode, ['power'], Time.current)
      data_results ? data_results : nil
    end

    # chart
    def aggregated(resource, mode, interval)
      registers_hash = sort_resource(resource)
      data_result_sets = registers_hash_to_data_result_sets(registers_hash, mode, interval)
      data_result_sets ? data_result_sets.first : nil
    end


private

    def registers_hash_to_data_results(registers_hash, mode, units, timestamp)
      if mode == :in
        profiles = IN_PROFILES
      elsif mode == :out
        profiles = OUT_PROFILES
      end

      data_results = []
      profiles.each do |profile|
        if registers_hash[profile.to_sym].any?
          registers_hash[profile.to_sym].each do |register|
            query_value_result = @facade.query_value(profile, timestamp, units)
            data_results << to_data_result(register, query_value_result, units, mode)
          end
        end
      end
      data_results
    end


    def registers_hash_to_data_result_sets(registers_hash, mode, interval)

      case interval.duration
      when :day
        resolution  = :day_to_minutes
        units       = ['power']
      when :month
        resolution  = :month_to_days
        units       = ['energy']
      when :year
        resolution  = :year_to_months
        units       = ['energy']
      else
        raise Buzzn::DataSourceError.new('unknown interval duration')
      end

      if mode == :in
        profiles = IN_PROFILES
      elsif mode == :out
        profiles = OUT_PROFILES
      end

      data_result_sets = []
      profiles.each do |profile|
        if registers_hash[profile.to_sym].any?
          registers_hash[profile.to_sym].each do |register|
            query_range_result = @facade.query_range(register.data_source, interval.from_as_time, interval.to_as_time, resolution, units)
            data_result_sets << to_data_result_set(register, query_range_result, units, mode)
          end
        end
      end
      data_result_sets
    end




    def to_data_result(register, query_value_result, units, mode)
      timestamp   = query_value_result.timestamp.to_time
      value       = query_value_result.energy_milliwatt_hour if units.include?('energy')
      value       = query_value_result.power_milliwatt if units.include?('power')
      resource_id = register.id
      Buzzn::DataResult.new(timestamp, value, resource_id, mode)
    end

    def to_data_result_set(register, query_range_result, units, mode)
      data_result_set = Buzzn::DataResultSet.milliwatt(register.id)
      factor = factor_from_register(register)
      query_range_result.each do |document|
        if units.include?('energy')
          timestamp = document['firstTimestamp']
          value     = document['sumEnergyMilliwattHour'] * factor
        end
        if units.include?('power')
          timestamp = document['firstTimestamp']
          value     = document['avgPowerMilliwatt'] * factor
        end
        data_result_set.add(timestamp, value, mode)
      end
      data_result_set
    end

    def factor_from_register(register)
       register.forecast_kwh_pa ? (register.forecast_kwh_pa/1000.0) : 1
    end



    def sort_resource(resource)
      case resource
      when Group
        hash = sort_registers(resource.registers)
      when Register::Base
        hash = sort_registers([resource])
      end
    end

    def sort_registers(registers)
      slp                 = []
      sep_bhkw            = []
      sep_pv              = []

      registers.each do |register|
        case register.data_source
        when :slp
          slp << register
        when :sep_bhkw
          sep_bhkw << register
        when :sep_pv
          sep_pv << register
        else
          raise Buzzn::DataSourceError.new('unknown register data_source')
        end
      end

      hash = {
        slp: slp,
        sep_bhkw: sep_bhkw,
        sep_pv: sep_pv
      }

      return hash
    end





  end
end
