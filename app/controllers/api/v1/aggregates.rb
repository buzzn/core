module API
  module V1
    class Aggregates < Grape::API
      include API::V1::Defaults
      resource :aggregates do






        desc "Aggregate Power"
        params do
          requires :register_id, type: String, desc: "register ID"
          optional :timestamp, type: DateTime
        end
        oauth2 false
        get 'present' do
          register = Register::Base.guareded_retrieve(permitted_params[:register_id])
          data_result = Buzzn::Application.config.current_power.for_register(register, permitted_params[:timestamp])

          { readings: [ { opterator: data_result.mode == :out ? '-' : '+',
	                  data: { timestamp: data_result.timestamp,
	                          power_milliwatt: data_result.value } } ],
            power_milliwatt: data_result.value }
        end







        desc "Aggregate Past"
        params do
          requires :register_id, type: String, desc: "register ID"
          optional :timestamp, type: DateTime
          optional :resolution, type: String, values: %w(
                                                        year_to_months
                                                        month_to_days
                                                        week_to_days
                                                        day_to_hours
                                                        day_to_minutes
                                                        hour_to_minutes
                                                        minute_to_seconds
                                                        )
        end
        oauth2 false
        get 'past' do
          register = Register::Base.guareded_retrieve(permitted_params[:register_id])
          timestamp = permitted_params[:timestamp] || Time.current
          result_set =
            case permitted_params[:resolution]
            when 'day_to_minutes'
              interval = Interval.day(timestamp)
              Buzzn::Application.config.power_charts.for_register(register, interval)
            when 'hour_to_minutes'
              interval = Interval.hour(timestamp)
              Buzzn::Application.config.power_charts.for_register(register, interval)         
            when 'minute_to_seconds'
              raise 'not implemented'
            when 'week_to_days'
              raise 'not implemented'
            when 'year_to_months'
              interval = Interval.year(timestamp)
              Buzzn::Application.config.energy_charts.for_register(register, interval)         
            when 'month_to_days'
              interval = Interval.month(timestamp)
              Buzzn::Application.config.energy_charts.for_register(register, interval)         
            end
          key = result_set.units == :milliwatt ? 'power_milliwatt' : 'energy_milliwatt_hour'
          result_set.collect do |i|
            { timestamp: i.timestamp, "#{key}": i.value }
          end
        end





      end
    end
  end
end
