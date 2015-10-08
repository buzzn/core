module API
  module V1
    class Friendships < Grape::API
      include API::V1::Defaults
      resource 'friendships' do



        desc "Return a friendship"
        params do
          requires :id, type: String, desc: "ID of the friendship"
        end
        get ":id" do
          Friendship.where(id: permitted_params[:id]).first!
        end


        desc "Return a friend from friendship"
        params do
          requires :id, type: String, desc: "ID of the friendship"
        end
        get ":id/friend" do
          friendship = Friendship.where(id: permitted_params[:id]).first!
          friendship.friend
        end



      end
    end
  end
end
