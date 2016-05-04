module API
  module V1
    class Aggregate < Grape::API
      include API::V1::Defaults
      resource :aggregate do


        desc "Aggregate Chart"
        params do
          optional :metering_point_ids, type: String, desc: "metering_point IDs"
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
        get 'chart' do
          doorkeeper_authorize! :public

          if params[:metering_point_ids]
            metering_points = MeteringPoint.where(id: params[:metering_point_ids].split(","))
            metering_point_ids = []
            metering_points.each do |metering_point|
              if metering_point.readable_by_world?
                metering_point_ids << metering_point.id
              elsif current_user
                if metering_point.readable_by?(current_user)
                  metering_point_ids << metering_point.id
                else
                  status 403
                end
              else
                status 401
              end
            end
            @aggregator = Aggregator.new({metering_point_ids: metering_point_ids })
          else
            @aggregator = Aggregator.new() # SLP
          end

          return @aggregator.chart({timestamp: params[:timestamp], resolution: params[:resolution]})
        end




      end
    end
  end
end
