module API
  module V1
    class MeteringPoints < Grape::API
      include API::V1::Defaults
      resource :metering_points do


        desc "Return a MeteringPoint"
        params do
          requires :id, type: String, desc: "ID of the metering_point"
        end
        get ":id", root: "metering_point" do
          MeteringPoint.where(id: permitted_params[:id]).first!
        end


        desc "Return a Chart from MeteringPoint"
        params do
          requires :id, type: String, desc: "ID of the metering_point"

        end
        get ":id/chart", root: "metering_point" do
          @metering_point = MeteringPoint.where(id: permitted_params[:id]).first!

          containing_timestamp = params[:containing_timestamp].nil? ? Time.now.to_i*1000 : params[:containing_timestamp]

          discovergy  = Discovergy.new(
                          @metering_point.metering_point_operator_contract.username,
                          @metering_point.metering_point_operator_contract.password
                        )

          request     = discovergy.getDataEveryDay(
                          @metering_point.meter.manufacturer_product_serialnumber,
                          containing_timestamp
                        )
          result = []
          if request['status'] == "ok"
            if request['result'].any?
              # TODO: make this nicer
              old_value = -1
              new_value = -1
              timestamp = -1
              i = 0
              request['result'].each do |item|
                if i == 0
                  old_value = item['energy']
                  timestamp = item['time']
                  i += 1
                  next
                end
                new_value = item['energy']
                result << [timestamp, (new_value - old_value)/10000000000.0]
                old_value = new_value
                timestamp = item['time']
                i += 1
              end
            else
              return request['status']
            end
          else
            return request['status']
          end

          return result
        end




      end
    end
  end
end
