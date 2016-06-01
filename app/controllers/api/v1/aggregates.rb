module API
  module V1
    class Aggregates < Grape::API
      include API::V1::Defaults
      resource :aggregates do






        desc "Aggregate Power"
        params do
          requires :metering_point_ids, type: String, desc: "metering_point IDs"
          optional :timestamp, type: DateTime
        end
        get 'present' do
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
          @aggregate = Aggregate.new({metering_point_ids: metering_point_ids })

          return @aggregate.present({timestamp: params[:timestamp]})
        end







        desc "Aggregate Past"
        params do
          requires :metering_point_ids, type: String, desc: "metering_point IDs"
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
        get 'past' do
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
          @aggregate = Aggregate.new({metering_point_ids: metering_point_ids })

          return @aggregate.past({timestamp: params[:timestamp], resolution: params[:resolution]})
        end






      end
    end
  end
end
