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





      end
    end
  end
end
