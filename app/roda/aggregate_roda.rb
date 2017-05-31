class AggregateRoda < BaseRoda

  route do |r|

    r.is 'present' do
      register = Register::Base.unguarded_retrieve(r.params['register_ids'])
      if current_user.nil? && !(register.group && register.group.readable_by_world?) && !register.readable_by_world?
        raise Buzzn::PermissionDenied.new
      end
      data_result = Buzzn::Boot::MainContainer['service.current_power'].for_register(register)#, permitted_params[:timestamp])
      unless r.params[:timestamp]
        # cache-control headers
        #etag(data_result.timestamp.to_s + data_result.value.to_s)
        #last_modified(Time.at(data_result.timestamp))
        #expires((data_result.expires_at - Time.current.to_f).to_i, current_user ? :private : :public)
      end
      
      {
        power_milliwatt: data_result.value.to_i,
        readings: [
          {
            operator: data_result.mode == :out ? '-' : '+',
            data: {
              timestamp: Time.at(data_result.timestamp),
              power_milliwatt: data_result.value.to_i
            }
          }
        ],
        timestamp: Time.at(data_result.timestamp)
      }
    end

    r.is 'past' do
      register = Register::Base.unguarded_retrieve(r.params['register_ids'])
      if current_user.nil? && !(register.group && register.group.readable_by_world?) && !register.readable_by_world?
        raise Buzzn::PermissionDenied.new
      end
      timestamp = r.params['timestamp'] || Time.current
      case r.params['resolution']
      when 'day_to_minutes'
        interval = Buzzn::Interval.day(timestamp)
      when 'hour_to_minutes'
        interval = Buzzn::Interval.hour(timestamp)
      when 'year_to_months'
        interval = Buzzn::Interval.year(timestamp)
      when 'month_to_days'
        interval = Buzzn::Interval.month(timestamp)
      else
        raise 'missing "resolution"'
      end
      result = Buzzn::Boot::MainContainer['service.charts'].for_register(register, interval)
      if result
        key = result.units == :milliwatt ? 'power_milliwatt' : 'energy_milliwatt_hour'
        (result.in + result.out).collect do |i|
          {
            timestamp: Time.at(i.timestamp),
            "#{key}": i.value.to_i
          }
        end
      else
        []
      end
    end
  end
end
