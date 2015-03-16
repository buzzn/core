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





        # curl -d '{"register_id": 20, "timestamp": "Fri, 16 Jan 2015 12:58:03 +0100", "watt_hour": "123456789"}' 'http://localhost:3000/api/v1/readings/register' -H Content-Type:application/json -v
        desc "Create Reading by register_id"
        params do
          requires :register_id, type: Integer, desc: "ID of the Register"
          requires :timestamp, type: DateTime, desc: "Timestamp of the Reading"
          requires :watt_hour, type: Integer, desc: "Watt Hour of the Reading. energy is in Wh"
        end
        post '/register' do
          Reading.create( register_id:  permitted_params[:register_id],
                          timestamp:    permitted_params[:timestamp],
                          watt_hour:    permitted_params[:watt_hour]
                          )
        end



        # curl -d '{"meter_manufacturer_name": "easy_meter", "meter_manufacturer_product_serialnumber": "60139082", "timestamp": "Sun, 15 Mar 2015 18:48:08 +0100", "in_watt_hour": "68539464401000",  "out_watt_hour": "68539464401000",  "in_power": "0", "out_power": "0" }' 'http://localhost:3000/api/v1/readings/meter' -H Content-Type:application/json -v
        desc "Create Reading by the Meter manufacturer and serialnumber"
        params do
          requires :meter_manufacturer_name, type: String, desc: "name of the meter manufacturer, for example: easy_meter"
          requires :meter_manufacturer_product_serialnumber, type: String, desc: "serialnumber of the meter"
          requires :timestamp, type: DateTime, desc: "Timestamp of the Reading"

          requires :in_watt_hour, type: Integer
          requires :in_power, type: Integer

          requires :out_watt_hour, type: Integer
          requires :out_power, type: Integer
        end
        post '/meter' do
          meter = Meter.where(
            manufacturer_name:                  permitted_params[:meter_manufacturer_name],
            manufacturer_product_serialnumber:  permitted_params[:meter_manufacturer_product_serialnumber]
            ).first

          readings = []
          meter.registers.each do |register|
            readings << Reading.create( register_id: register.id,
                            timestamp:   permitted_params[:timestamp],
                            watt_hour:   permitted_params["#{register.mode}_watt_hour".to_sym],
                            power:       permitted_params["#{register.mode}_power".to_sym]
                          )
          end
          return readings
        end





      end


    end
  end
end
