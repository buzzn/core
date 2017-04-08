module API
  module V1
    class Readings < Grape::API
      include API::V1::Defaults
      resource :readings do


        desc "Return a Reading"
        params do
          requires :id, type: String, desc: "ID of the Reading"
        end
        get ":id" do
          reading = Reading.guarded_retrieve(current_user, permitted_params)
          render(reading, meta: {
            updatable: reading.updatable_by?(current_user),
            deletable: reading.deletable_by?(current_user)
          })
        end


        desc "Create a Reading"
        params do
          requires :register_id,           type: String,   desc: "The ID of register"
          requires :timestamp,             type: DateTime, desc: "DateTime of the reading"
          requires :energy_milliwatt_hour, type: Integer,  desc: "energy in Milliwatt Hour"
          requires :power_milliwatt,       type: Integer,  desc: "power in Milliwatt"
          requires :reason,                type: String,  desc: "The reason for this reading", values: Reading::reasons
          requires :source,                type: String,  desc: "The source of this reading", values: Reading::sources
          requires :quality,               type: String,  desc: "The quality of this reading", values: Reading::qualities
          requires :meter_serialnumber,    type: String, desc: "The serialnumber of the meter"
        end
        post do
          register = Register::Base.unguarded_retrieve(permitted_params[:register_id])
          if Reading.creatable_by?(current_user, register)
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
