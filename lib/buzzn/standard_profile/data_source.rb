module Buzzn::StandardProfile
  class DataSource < Buzzn::DataSource
    NAME = :standard_profile

    RESOLUTION = 15.minutes

    IN_PROFILES = [:slp]
    OUT_PROFILES = [:sep_bhkw, :sep_pv]

    def initialize(facade = Facade.new)
      @facade = facade
    end

    # single_value
    def single_aggregated(resource, mode)
      case resource
      when Register::Real
        single_aggregated_register(resource, mode)
      when Group::Base
        single_aggregated_group(resource, mode)
      else
        nil
      end
    end

    # value_list
    def collection(resource, mode)
      results = []
      current = Time.current
      results = resource.registers.collect do |register|
        single_aggregated_register(register, mode, current)
      end
      results.compact!
      expires_at = results.collect{ |c| c.timestamp }.min
      result = Buzzn::DataResultArray.new(expires_at)
      result.replace(results) # set the array
      result
    end

    # chart
    def aggregated(resource, mode, interval)
      case resource
      when Register::Real
        aggregated_register(resource, mode, interval)
      when Group::Base
        aggregated_group(resource, mode, interval)
      else
        nil
      end
    end


private
    def single_aggregated_register(register, mode, time = nil)
      profile_type = get_profile_type(register)
      if profile_type && register.direction == mode
        if result = @facade.query_value(profile_type, time || Time.current)
          factor = factor_from_register(register)
          Buzzn::DataResult.new(result.timestamp.to_time,
                                factor * result.power_milliwatt,
                                register.id, mode,
                                # only use expires on current time
                                time ? nil : result.timestamp.to_time)
        end
      end
    end

    def single_aggregated_group(group, mode)
      value = 0
      current = Time.current

      # produce a map from register (sample) to how registers have
      # the same profile_type
      profile_types = {}
      registers = {}
      group.registers.each do |register|
        profile_type = get_profile_type(register)
        reg = profile_types[profile_type]
        if reg
          # count how many registers are for that profile_type
          registers[reg] += 1
        else
          # the first register is take as sample for the profile_type
          registers[register] = 1
          profile_types[profile_type] = register
        end
      end
      # now the registers map has a register sample mapped to how many
      # registers have the same profile_type
      registers.each do |register, multiplier|
        if val = single_aggregated_register(register, mode, current)
          value += val.value * multiplier
        end
      end
      Buzzn::DataResult.new(current, value, group.id, mode)
    end

    def aggregated_register(register, mode, interval)
      profile_type = get_profile_type(register)
      if profile_type && get_profile_types(mode).include?(profile_type)
        query_range_result = @facade.query_range(profile_type, interval)
        to_data_result_set(register, query_range_result, mode)
      end
    end

    def aggregated_group(group, mode, interval)
      units = interval.hour? || interval.day? ? :milliwatt : :milliwatt_hour
      result = Buzzn::DataResultSet.send(units, group.id)
      profile_types = get_profile_types(mode)
      group.registers.each do |register|
        if profile_type = get_profile_type(register) && profile_types.include?(profile_type)
          query_range_result = @facade.query_range(profile_type, interval)
          set = to_data_result_set(register, query_range_result, mode)
          result.add_all(set, interval.duration)
        end
      end
      result
    end

    def get_profile_types(mode)
      if mode == :in
        profiles = IN_PROFILES
      elsif mode == :out
        profiles = OUT_PROFILES
      else
        raie ArgumentError.new "unknown mode: #{mode}"
      end
    end

    def get_profile_type(register)
      if register.data_source == :standard_profile
        if register.direction == :in
          :slp
        else
          if register.devices.any? && register.devices.first.primary_energy == 'sun'
            :sep_pv
          else
            :sep_bhkw
          end
        end
      end
    end

    def to_data_result_set(register, query_range_result, mode)
      unit = query_range_result.first['sumEnergyMilliwattHour'] ? :milliwatt_hour : :milliwatt
      data_result_set = Buzzn::DataResultSet.send(unit, register.id)
      factor = factor_from_register(register)
      query_range_result.each do |document|
        timestamp = document['firstTimestamp']
        value     = (document['sumEnergyMilliwattHour'] || document['avgPowerMilliwatt']) * factor
        data_result_set.add(timestamp, value, mode)
      end
      data_result_set
    end

    def factor_from_register(register)
       register.forecast_kwh_pa ? (register.forecast_kwh_pa/1000.0) : 1.0
    end
  end
end

