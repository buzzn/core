module API
  module V1
    class Readings < Grape::API
      include API::V1::Defaults
      resource :readings do

        before do
          doorkeeper_authorize! :admin, :public
        end


        desc "Return a Reading"
        params do
          requires :id, type: String, desc: "ID of the Device"
        end
        get ":id" do
          reading = Reading.find(params[:id])
          if current_user && reading.readable_by?(current_user)
            reading
          else
            status 403
          end
        end


        desc "Create a Reading"
        params do
          requires :metering_point_id, type: String,   desc: "The ID of metering point"
          requires :timestamp,         type: DateTime, desc: "DateTime of the reading"
          requires :watt_hour,         type: Integer,  desc: "work in watt hour"
          requires :power,             type: Integer,  desc: "current power in Watt"
        end
        post do
          reading = Reading.new(
            metering_point_id: params[:metering_point_id],
            timestamp: params[:timestamp],
            watt_hour: params[:watt_hour],
            power: params[:power]
          )
          if current_user && current_user.can_create?(reading)
            reading.save!
            return reading
          else
            status 403
          end
        end

      end
    end
  end
end
