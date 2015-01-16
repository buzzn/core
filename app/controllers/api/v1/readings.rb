module API
  module V1
    class Readings < Grape::API
      include API::V1::Defaults


      resource :readings do

        desc "Get Last Reading by Register ID"
        params do
          requires :register_id, type: Integer, desc: "ID of the Register"
        end
        get do
          Reading.last_by_register_id(permitted_params[:register_id])
        end

        # test: curl -d '{"register_id": 20, "timestamp": "Fri, 16 Jan 2015 12:58:03 +0100", "watt_hour": "123456789"}' 'http://localhost:3000/api/v1/readings' -H Content-Type:application/json -v
        desc "Create Reading"
        params do
          requires :register_id, type: Integer, desc: "ID of the Register"
          requires :timestamp, type: DateTime, desc: "Timestamp of the Reading"
          requires :watt_hour, type: Integer, desc: "Watt Hour of the Reading. energy is in Wh"
        end
        post do
          Reading.create( register_id:  permitted_params[:register_id],
                          timestamp:    permitted_params[:timestamp],
                          watt_hour:    permitted_params[:watt_hour]
                          )
        end

      end


    end
  end
end
