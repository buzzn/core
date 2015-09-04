module API
  module V1
    class Profiles < Grape::API
      include API::V1::Defaults
      resource :profiles do



        desc "Return all profiles"
        get "", root: :profiles do
          Profile.all
        end



        desc "Return a Profile"
        params do
          requires :id, type: String, desc: "ID of the profile"
        end
        get ":id", root: "profile" do
          Profile.where(id: permitted_params[:id]).first!
        end



      end
    end
  end
end
