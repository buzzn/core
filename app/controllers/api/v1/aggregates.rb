module API
  module V1
    class Aggregates < Grape::API
      include API::V1::Defaults
      resource :aggregates do






        desc "Aggregate Power"
        params do
          requires :register_ids, type: String, desc: "register ID"
          optional :timestamp, type: Time
        end
        oauth2 false
        get 'present' do
          register = Register::Base.guarded_retrieve(current_user, permitted_params[:register_ids])
          data_result = Buzzn::Application.config.current_power.for_register(register, permitted_params[:timestamp])

          unless permitted_params[:timestamp]
            # cache-control headers
            etag(data_result.timestamp.to_s + data_result.value.to_s)
            last_modified(Time.at(data_result.timestamp))
            expires((data_result.expires_at - Time.current.to_f).to_i, current_user ? :private : :public)
          end

          { power_milliwatt: (data_result.value * 1000).to_i,
            readings: [ { opterator: data_result.mode == :out ? '-' : '+',
	                  data: { timestamp: Time.at(data_result.timestamp),
	                          power_milliwatt: (data_result.value * 1000).to_i } } ],
            timestamp: Time.at(data_result.timestamp) }
        end







        desc "Aggregate Past"
        params do
          requires :register_ids, type: String, desc: "register ID"
          optional :timestamp, type: Time
          requires :resolution, type: String, values: %w(
                                                        year_to_months
                                                        month_to_days
                                                        day_to_minutes
                                                        hour_to_minutes
                                                        )
        end
        oauth2 false
        get 'past' do
          register = Register::Base.guarded_retrieve(current_user, permitted_params[:register_ids])
          timestamp = permitted_params[:timestamp] || Time.current
          case permitted_params[:resolution]
          when 'day_to_minutes'
            interval = Buzzn::Interval.day(timestamp)
          when 'hour_to_minutes'
            interval = Buzzn::Interval.hour(timestamp)
          when 'year_to_months'
            interval = Buzzn::Interval.year(timestamp)
          when 'month_to_days'
            interval = Buzzn::Interval.month(timestamp)
          end
          result = Buzzn::Application.config.charts.for_register(register, interval)
          if result
            key = result.units == :milliwatt ? 'power_milliwatt' : 'energy_milliwatt_hour'
            (result.in + result.out).collect do |i|
              { timestamp: Time.at(i.timestamp), "#{key}": i.value.to_i }
            end
          else
            []
          end
        end





      end
    end
  end
end
