module API
  module V1
    class Profiles < Grape::API
      include API::V1::Defaults
      resource 'profiles' do

        before do
          doorkeeper_authorize! :public
        end

        desc "Return all profiles"
        paginate(per_page: per_page=10)
        get do
          @per_page     = params[:per_page] || per_page
          @page         = params[:page] || 1
          @total_pages  = Profile.all.page(@page).per(@per_page).total_pages
          paginate(render(Profile.all, meta: { total_pages: @total_pages }))
        end


        desc "Return a Profile"
        params do
          requires :id, type: String, desc: "ID of the Profile"
        end
        get ":id" do
          profile = Profile.where(id: permitted_params[:id]).first!
          if current_user && profile.readable_by?(current_user)
            return profile
          else
            status 403
          end
        end


        desc "Create a Profile"
        params do
          requires :user_name, type: String
          requires :first_name, type: String
          requires :last_name, type: String
        end
        post do
          if current_user && current_user.can_create?(Profile)
            Profile.create!({
              user_name: params[:user_name],
              first_name: params[:first_name],
              last_name: params[:last_name]
            })
          else
            status 403
          end
        end





      end
    end
  end
end
