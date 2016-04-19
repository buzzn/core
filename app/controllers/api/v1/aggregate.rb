module API
  module V1
    class Aggregate < Grape::API
      include API::V1::Defaults
      resource :aggregate do


        desc "Aggregate Readings"
        params do
          requires :metering_point_ids, type: String, desc: "Meterings Point IDs"
          requires :timestamp, type: DateTime, default: DateTime.now.in_time_zone
          requires :resolution, type: String, default: 'day_to_hours', values: %w(
                                                                          year_to_months
                                                                          month_to_days
                                                                          week_to_days
                                                                          day_to_hours
                                                                          day_to_minutes
                                                                          hour_to_minutes
                                                                          minute_to_seconds
                                                                        )
        end
        get do
          doorkeeper_authorize! :public
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

          resolution  = params[:resolution].to_sym
          timestamp   = params[:timestamp].to_i*1000
          aggregation = Reading.aggregate( resolution, metering_point_ids, timestamp)

          items = []
          aggregation.each do |item|
            items << [
              item['firstTimestamp'],
              item['consumption'],
              item['avgPower']
            ]
          end

          return items
        end




      end
    end
  end
end
