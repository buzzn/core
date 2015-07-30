module API
  module V1
    class Meters < Grape::API
      include API::V1::Defaults
      resource :meters do


        desc "Get meter by ID"
        params do
          requires :id, type: Integer, desc: "ID of the meter"
        end
        get ":id", root: "meter" do
          Meter.where(id: permitted_params[:id]).first!
        end



        desc "Get Meter by Manufacturer Name and Serialnumber"
        params do
          requires :manufacturer_name, type: String, desc: "Manufacturer Name of the Meter"
          requires :manufacturer_product_serialnumber, type: String, desc: "Manufacturer Product Serialnumber of the Meter"
        end
        get do
          Meter.where(
            manufacturer_name: permitted_params[:manufacturer_name],
            manufacturer_product_serialnumber: permitted_params[:manufacturer_product_serialnumber]
            ).first!
        end


      end
    end
  end
end
