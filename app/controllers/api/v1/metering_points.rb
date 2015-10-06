module API
  module V1
    class MeteringPoints < Grape::API
      include API::V1::Defaults
      resource 'metering-points' do



        desc "Return all MeteringPoints"
        get "" do
          guard!
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





      end
    end
  end
end
