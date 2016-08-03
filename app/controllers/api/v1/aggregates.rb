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
        oauth2 false
        get 'present' do

          metering_points = MeteringPoint.where(id: permitted_params[:metering_point_ids].split(","))
          metering_points_hash = Aggregate.sort_metering_points(metering_points)

          if metering_points.size > 5
            error!('maximum 5 metering_points per request', 413)
          else
            if metering_points_hash[:data_sources].size > 1
              error!('it is not possible to sum metering_points with differend data_source', 406)
            else
              metering_points.each do |metering_point|
                unless metering_point.readable_by?(current_user)
                  error!('Forbidden', 403)
                end
              end
              return Aggregate.new(metering_points_hash).present( { timestamp: permitted_params[:timestamp] })
            end
          end

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
        oauth2 false
        get 'past' do

          metering_points = MeteringPoint.where(id: permitted_params[:metering_point_ids].split(","))
          metering_points_hash = Aggregate.sort_metering_points(metering_points)

          if metering_points.size > 5
            error!('maximum 5 metering_points per request', 413)
          else
            if metering_points_hash[:data_sources].size > 1
              error!('it is not possible to sum metering_points with differend data_source', 406)
            else
              metering_points.each do |metering_point|
                unless metering_point.readable_by?(current_user)
                  error!('Forbidden', 403)
                end
              end
              return Aggregate.new(metering_points_hash).past( { timestamp: permitted_params[:timestamp], resolution: params[:resolution] })
            end
          end

        end






      end
    end
  end
end
