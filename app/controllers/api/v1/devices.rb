module API
  module V1
    class Devices < Grape::API
      include API::V1::Defaults
      resource :devices do



        desc "Return a Device"
        params do
          requires :id, type: String, desc: "ID of the Device"
        end
        get ":id", root: "device" do
          guard!
          Device.where(id: permitted_params[:id]).first!
        end



      end
    end
  end
end
