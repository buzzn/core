module API
  module V1
    class Readings < Grape::API
      include API::V1::Defaults
      resource :readings do

        before do
          doorkeeper_authorize! :manager, :public
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
          requires :meter_id,                 type: String,   desc: "The ID of meter"
          requires :timestamp,                type: DateTime, desc: "DateTime of the reading"
          requires :energy_a_milliwatt_hour,  type: Integer,  desc: "energy A(often consumption) in Milliwatt Hour for the first register"
          optional :energy_b_milliwatt_hour,  type: Integer,  desc: "energy B(often production) in Milliwatt Hour for the second register"
          requires :power_a_milliwatt,        type: Integer,  desc: "power A(often consumption) in Milliwatt"
          optional :power_b_milliwatt,        type: Integer,  desc: "power B(often production) in Milliwatt"
        end

        post do
          reading = Reading.new(
            meter_id:                 params[:meter_id],
            timestamp:                params[:timestamp],
            energy_a_milliwatt_hour:  params[:energy_a_milliwatt_hour],
            energy_b_milliwatt_hour:  params[:energy_b_milliwatt_hour],
            power_a_milliwatt:        params[:power_a_milliwatt],
            power_b_milliwatt:        params[:power_b_milliwatt]
          )
          if current_user && current_user.can_create?(reading)
            reading.save!

            # if reading.timestamp > 30.seconds.ago # don't push old readings
            #   Sidekiq::Client.push({
            #    'class' => PushReadingWorker,
            #    'queue' => :default,
            #    'args' => [reading.meter_id,
            #               reading.energy_a_milliwatt_hour,
            #               reading.energy_b_milliwatt_hour,
            #               reading.power_milliwatt,
            #               reading.timestamp]
            #   })
            # end

            return reading
          else
            status 403
          end
        end

      end
    end
  end
end
