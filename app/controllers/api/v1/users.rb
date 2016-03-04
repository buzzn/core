module API
  module V1
    class Users < Grape::API
      include API::V1::Defaults
      resource 'users' do

        before do
          doorkeeper_authorize! :admin, :public
        end

        desc "Return me"
        get "me" do
          current_user
        end

        desc "Return all Users"
        paginate(per_page: per_page=10)
        get do
          @per_page     = params[:per_page] || per_page
          @page         = params[:page] || 1
          @total_pages  = User.all.page(@page).per(@per_page).total_pages
          paginate(render(User.all, meta: { total_pages: @total_pages }))
        end


        desc "Return a User"
        params do
          requires :id, type: String, desc: "ID of the user"
        end
        get ":id" do
          user = User.where(id: permitted_params[:id]).first!
          if current_user && user.profile.readable_by?(current_user)
            return user
          else
            status 403
          end
        end


        desc "Create a User"
        params do
          requires :email, type: String
          requires :password, type: String
          requires :first_name, type: String
          requires :last_name, type: String
        end
        post do
          User.create!(
            email:    params[:email],
            password: params[:password],
            profile:  Profile.new( user_name: params[:user_name], first_name: params[:first_name], last_name:  params[:last_name] )
            )
        end


        desc "Return the related groups for User"
        params do
          requires :id, type: String, desc: "ID of the profile"
        end
        get ":id/groups" do
          user = User.where(id: permitted_params[:id]).first!
          user.metering_points.collect(&:group).compact.uniq
        end



        desc "Return the related metering-points for User"
        params do
          requires :id, type: String, desc: "ID of the User"
        end
        get ":id/metering-points" do
          doorkeeper_authorize! :public
          user = User.where(id: permitted_params[:id]).first!
          user.metering_points
        end



        desc "Return the related friends for User"
        params do
          requires :id, type: String, desc: "ID of the User"
        end
        get ":id/friends" do
          user = User.where(id: permitted_params[:id]).first!
          user.friends
        end



        desc "Return the related devices for User"
        params do
          requires :id, type: String, desc: "ID of the User"
        end
        get ":id/devices" do
          user = User.where(id: permitted_params[:id]).first!
          Device.with_role(:manager, user)
        end




      end
    end
  end
end
