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
          register = Register::Base.guarded_retrieve(current_user, permitted_params[:register_id])
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
                                                        day_to_minutes
                                                        hour_to_minutes
                                                        )
        end
        oauth2 false
        get 'past' do
          register = Register::Base.guarded_retrieve(current_user, permitted_params[:register_id])
          timestamp = permitted_params[:timestamp] || Time.current
          case permitted_params[:resolution]
          when 'day_to_minutes'
            interval = Interval.day(timestamp)
          when 'hour_to_minutes'
            interval = Interval.hour(timestamp)
          when 'year_to_months'
            interval = Interval.year(timestamp)
          when 'month_to_days'
            interval = Interval.month(timestamp)
          end
          result = Buzzn::Application.config.charts.for_register(register, interval)
          key = result.units == :milliwatt ? 'power_milliwatt' : 'energy_milliwatt_hour'
          result.collect do |i|
            { timestamp: i.timestamp, "#{key}": i.value }
          end
        end





      end
    end
  end
end
