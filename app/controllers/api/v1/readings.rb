module API
  module V1
    class Readings < Grape::API
      include API::V1::Defaults
      resource :readings do

        before do
          doorkeeper_authorize!
        end


        desc "Return a Reading"
        params do
          requires :id, type: String, desc: "ID of the Device"
        end
        get ":id" do
          reading = Reading.find(params[:id])
          if current_user && reading.readable_by?(current_user)
            reading
          else
            status 403
          end
        end




      end
    end
  end
end
