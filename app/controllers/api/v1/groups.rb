module API
  module V1
    class Groups < Grape::API
      include API::V1::Defaults

      resource :groups do
        desc "Return all groups"
        get "", root: :groups do
          Group.all
        end

        desc "Return a Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
        get ":id", root: "group" do
          Group.where(id: permitted_params[:id]).first!
        end
      end

    end
  end
end
