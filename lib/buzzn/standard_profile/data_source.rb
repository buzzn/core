module Buzzn::StandardProfile
  class DataSource

    def to_map(resource)
      case resource
      when Group
        to_group_map(resource)
      when Register
        to_register_map(resource)
      end
    end


    def aggregated(register_or_group, interval, mode)
      response = @facade.readings(broker, interval, mode, false)
      result = parse_aggregated_data(response.body, interval, mode, two_way_meter, register_or_group.id)
      result.freeze
      result
    end


  end
end
