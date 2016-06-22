module API
  module V1
    class Profiles < Grape::API
      include API::V1::Defaults
      resource 'profiles' do

        desc "Return all profiles"
        paginate(per_page: per_page=10)
        get do
          doorkeeper_authorize! :admin
          @per_page     = params[:per_page] || per_page
          @page         = params[:page] || 1
          @total_pages  = Profile.all.page(@page).per_page(@per_page).total_pages
          paginate(render(Profile.all, meta: { total_pages: @total_pages }))
        end


        desc "Return a Profile"
        params do
          requires :id, type: String, desc: "ID of the Profile"
        end
        get ":id" do
          Profile.where(id: permitted_params[:id]).first!
        end


        desc "Create a Profile"
        params do
          requires :user_name, type: String
          requires :first_name, type: String
          requires :last_name, type: String
        end
        post do
          doorkeeper_authorize! :public
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


        desc 'Return profile groups'
        params do
          requires :id, type: String, desc: "ID of the Profile"
        end
        get ':id/groups' do
          profile = Profile.where(id: permitted_params[:id]).first!
          user = User.find(profile.user_id)
          group_ids = user.accessible_groups.map(&:id)

          if current_user && profile.readable_by?(current_user)
            if current_user.friend?(user)
              Group.where(id: group_ids).where.not(readable: 'members')
            else
              Group.where(id: group_ids).where.not(readable: ['friends', 'members'])
            end
          elsif profile.readable_by_world?
            Group.where(id: group_ids, readable: 'world')
          else
            status 403
          end
        end


        desc 'Return profile friends'
        params do
          requires :id, type: String, desc: "ID of the Profile"
        end
        get ':id/friends' do
          profile = Profile.where(id: permitted_params[:id]).first!

          if (current_user && profile.readable_by?(current_user)) || profile.readable_by_world?
            User.find(profile.user_id).friends
          else
            status 403
          end
        end

        desc 'Return profile metering points'
        params do
          requires :id, type: String, desc: "ID of the Profile"
        end
        get ':id/metering-points' do
          profile               = Profile.where(id: permitted_params[:id]).first!
          user                  = User.find(profile.user_id)
          metering_points_ids   = MeteringPoint.accessible_by_user(user).map(&:id)

          if current_user && profile.readable_by?(current_user)
            if current_user.friend?(user)
              MeteringPoint.where(id: metering_points_ids).where.not(readable: 'members')
            else
              MeteringPoint.where(id: metering_points_ids).where.not(readable: ['friends', 'members'])
            end
          elsif profile.readable_by_world?
            MeteringPoint.where(id: metering_points_ids, readable: 'world')
          else
            status 403
          end
        end


      end
    end
  end
end
