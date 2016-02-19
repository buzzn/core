module API
  module V1
    class MeteringPoints < Grape::API
      include API::V1::Defaults
      resource 'metering-points' do



        desc "Return all MeteringPoints"
        get "" do
          if current_user
            MeteringPoint.all
          else
            MeteringPoint.where(readable: 'world')
          end
        end



        desc "Return a MeteringPoint"
        params do
          requires :id, type: String, desc: "ID of the metering_point"
        end
        get ":id" do
          MeteringPoint.where(id: permitted_params[:id]).first!
        end


        desc "Return the related devices for MeteringPoint"
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
        end
        get ":id/devices" do
          metering_point = MeteringPoint.where(id: permitted_params[:id]).first!
          metering_point.devices
        end


        desc "Return the related users for MeteringPoint"
        params do
          requires :id, type: String, desc: "ID of the MeteringPoint"
        end
        get ":id/users" do
          metering_point = MeteringPoint.where(id: permitted_params[:id]).first!
          metering_point.users
        end




      end
    end
  end
end
