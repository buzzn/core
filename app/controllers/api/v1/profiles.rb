module API
  module V1
    class Profiles < Grape::API
      include API::V1::Defaults
      resource 'profiles' do

        desc "Return all profiles"
        paginate(per_page: per_page=10)
        oauth2 :full
        get do
          @per_page     = params[:per_page] || per_page
          @page         = params[:page] || 1
          @total_pages  = Profile.all.page(@page).per_page(@per_page).total_pages
          paginate(render(Profile.all, meta: { total_pages: @total_pages }))
        end


        desc "Return a Profile"
        params do
          requires :id, type: String, desc: "ID of the Profile"
        end
        oauth2 false
        get ":id" do
          Profile.where(id: permitted_params[:id]).first!
        end


        desc "Create a Profile"
        params do
          requires :user_name, type: String
          requires :first_name, type: String
          requires :last_name, type: String
        end
        oauth2 :public, :full
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


        desc 'Return profile groups'
        params do
          requires :id, type: String, desc: "ID of the Profile"
        end
        paginate(per_page: per_page=10)
        oauth2 false
        get ':id/groups' do
          profile   = Profile.where(id: permitted_params[:id]).first!
          user      = User.find(profile.user_id)
          group_ids = user.accessible_groups.map(&:id)
          @per_page = params[:per_page] || per_page
          @page     = params[:page] || 1

          if current_user && profile.readable_by?(current_user)
            filter = {}
            if current_user.friend?(user)
              filter = { readable: 'members' }
            else
              filter = { readable: ['friends', 'members'] }
            end
            groups        = Group.where(id: group_ids).where.not(filter)
            @total_pages  = groups.page(@page).per_page(@per_page).total_pages
            paginate(render(groups, meta: { total_pages: @total_pages }))
          elsif profile.readable_by_world?
            groups        = Group.where(id: group_ids, readable: 'world')
            @total_pages  = groups.page(@page).per_page(@per_page).total_pages
            paginate(render(groups, meta: { total_pages: @total_pages }))
          else
            status 403
          end
        end


        desc 'Return profile friends'
        params do
          requires :id, type: String, desc: "ID of the Profile"
        end
        paginate(per_page: per_page=10)
        oauth2 false
        get ':id/friends' do
          profile = Profile.where(id: permitted_params[:id]).first!

          if (current_user && profile.readable_by?(current_user)) || profile.readable_by_world?
            @per_page     = params[:per_page] || per_page
            @page         = params[:page] || 1
            friends       = User.find(profile.user_id).friends
            @total_pages  = friends.page(@page).per_page(@per_page).total_pages
            paginate(render(friends, meta: { total_pages: @total_pages }))
          else
            status 403
          end
        end

        desc 'Return profile metering points'
        params do
          requires :id, type: String, desc: "ID of the Profile"
        end
        paginate(per_page: per_page=10)
        oauth2 false
        get ':id/metering-points' do
          profile               = Profile.where(id: permitted_params[:id]).first!
          user                  = User.find(profile.user_id)
          metering_points_ids   = MeteringPoint.accessible_by_user(user).map(&:id)
          @per_page             = params[:per_page] || per_page
          @page                 = params[:page] || 1

          if current_user && profile.readable_by?(current_user)
            filter = {}
            if current_user.friend?(user)
              filter = { readable: 'members' }
            else
              filter = { readable: ['friends', 'members'] }
            end
            metering_points = MeteringPoint.where(id: metering_points_ids).where.not(filter)
            @total_pages    = metering_points.page(@page).per_page(@per_page).total_pages
            paginate(render(metering_points, meta: { total_pages: @total_pages }))
          elsif profile.readable_by_world?
            metering_points = MeteringPoint.where(id: metering_points_ids, readable: 'world')
            @total_pages    = metering_points.page(@page).per_page(@per_page).total_pages
            paginate(render(metering_points, meta: { total_pages: @total_pages }))
          else
            status 403
          end
        end


      end
    end
  end
end
