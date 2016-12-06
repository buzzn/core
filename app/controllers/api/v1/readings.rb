module API
  module V1
    class Readings < Grape::API
      include API::V1::Defaults
      resource :readings do


        desc "Return a Reading"
        params do
          requires :id, type: String, desc: "ID of the Reading"
        end
        oauth2 :simple, :full
        get ":id" do
          Reading.guarded_retrieve(current_user, permitted_params)
        end


        desc "Create a Reading"
        params do
          requires :register_id,              type: String,   desc: "The ID of register"
          requires :timestamp,                type: DateTime, desc: "DateTime of the reading"
          requires :energy_a_milliwatt_hour,  type: Integer,  desc: "energy A(often consumption) in Milliwatt Hour for the first register"
          optional :energy_b_milliwatt_hour,  type: Integer,  desc: "energy B(often production) in Milliwatt Hour for the second register"
          requires :power_a_milliwatt,        type: Integer,  desc: "power A(often consumption) in Milliwatt"
          optional :power_b_milliwatt,        type: Integer,  desc: "power B(often production) in Milliwatt"
        end
        oauth2 :full, :smartmeter
        post do
          meter = Meter.unguarded_retrieve(permitted_params[:meter_id])
          if Reading.creatable_by?(current_user, meter)
            reading = Reading.create(permitted_params)

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

            created_response(reading)
          else
            status 403
          end
        end

      end
    end
  end
end
