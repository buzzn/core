module API
  module V1
    class Profiles < Grape::API
      include API::V1::Defaults
      resource 'profiles' do



        desc "Return me"
        get "me" do
          guard!
          current_user.profile
        end



        desc "Return all profiles"
        paginate(per_page: per_page=10)
        get "" do
          @per_page     = params[:per_page] || per_page
          @page         = params[:page] || 1
          @total_pages  = Profile.all.page(@page).per(@per_page).total_pages
          paginate(render(Profile.all, meta: { total_pages: @total_pages }))
        end



        desc "Return a Profile"
        params do
          requires :id, type: String, desc: "ID of the profile"
        end
        get ":id" do
          Profile.where(id: permitted_params[:id]).first!
        end



        desc "Return the related groups for Profile"
        params do
          requires :id, type: String, desc: "ID of the profile"
        end
        get ":id/groups" do
          profile = Profile.where(id: permitted_params[:id]).first!
          profile.metering_points.collect(&:group).compact.uniq
        end


        desc "Return the related metering_points for Profile"
        params do
          requires :id, type: String, desc: "ID of the profile"
        end
        get ":id/metering-points" do
          profile = Profile.where(id: permitted_params[:id]).first!
          profile.metering_points
        end



        desc "Return the related friendships for Profile"
        params do
          requires :id, type: String, desc: "ID of the profile"
        end
        get ":id/friendships" do
          profile = Profile.where(id: permitted_params[:id]).first!
          profile.user.friendships
        end



        desc "Return the related devices for Profile"
        params do
          requires :id, type: String, desc: "ID of the profile"
        end
        get ":id/devices" do
          profile = Profile.where(id: permitted_params[:id]).first!
          Device.with_role(:manager, profile.user)
        end





      end
    end
  end
end
