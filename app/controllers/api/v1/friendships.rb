module API
  module V1
    class Friendships < Grape::API
      include API::V1::Defaults
      resource :friendships do



        desc "Return a friendship"
        params do
          requires :id, type: String, desc: "ID of the friendship"
        end
        get ":id", root: "friendship" do
          Friendship.where(id: permitted_params[:id]).first!
        end
      end




    end
  end
end
