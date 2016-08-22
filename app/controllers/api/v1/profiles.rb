module API
  module V1
    class Profiles < Grape::API
      include API::V1::Defaults
      resource 'profiles' do

        desc "Return all profiles"
        params do
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :full
        get do
          per_page     = permitted_params[:per_page]
          page         = permitted_params[:page]
          ids  = Profile.all.select { |p| p.readable_by?(current_user) }
          profiles = Profile.where(id: ids)
          total_pages = profiles.page(page).per_page(per_page).total_pages
          paginate(render(profiles, meta: { total_pages: total_pages }))
        end


        desc "Return a Profile"
        params do
          requires :id, type: String, desc: "ID of the Profile"
        end
        oauth2 false
        get ":id" do
          profile = Profile.find(permitted_params[:id])
          if profile.readable_by?(current_user)
            profile
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
        oauth2 :public, :full
        post do
          if Profile.creatable_by?(current_user)
            profile = Profile.create!(permitted_params)
            created_response(profile)
          else
            status 403
          end
        end


        desc 'Return profile groups'
        params do
          requires :id, type: String, desc: "ID of the Profile"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get ':id/groups' do
          profile   = Profile.find(permitted_params[:id])

          if profile.readable_by?(current_user)
            per_page = permitted_params[:per_page]
            page     = permitted_params[:page]
            user     = profile.user
            if current_user.nil?
              filter = [ 'groups.readable = ?', 'world' ]
            elsif current_user.friend?(user)
              filter = [ 'groups.readable != ?', 'members' ]
            else
              filter = [ 'groups.readable NOT IN (?)', ['friends', 'members'] ]
            end
            groups        = user.accessible_groups_relation.where(*filter)
            total_pages   = groups.page(page).per_page(per_page).total_pages
            paginate(render(groups, meta: { total_pages: total_pages }))
          else
            status 403
          end
        end


        desc 'Return profile friends'
        params do
          requires :id, type: String, desc: "ID of the Profile"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get ':id/friends' do
          profile = Profile.find(permitted_params[:id])

          if profile.readable_by?(current_user)
            ids          = profile.user.friends.select do |f|
              f.readable_by?(current_user)
            end
            per_page     = permitted_params[:per_page]
            page         = permitted_params[:page]
            friends      = User.where(id: ids)
            total_pages  = friends.page(page).per_page(per_page).total_pages
            paginate(render(friends, meta: { total_pages: total_pages }))
          else
            status 403
          end
        end

        desc 'Return profile metering points'
        params do
          requires :id, type: String, desc: "ID of the Profile"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get ':id/metering-points' do
          profile              = Profile.find(permitted_params[:id])

          if profile.readable_by?(current_user)
            per_page = permitted_params[:per_page]
            page     = permitted_params[:page]
            if profile.readable_by_world? && current_user.nil?
              filter = [ 'readable = ?', 'world' ]
            elsif current_user.friend?(profile.user)
              filter = [ 'readable != ?', 'members' ]
            else
              filter = [ 'readable NOT IN (?)', ['friends', 'members'] ]
            end
            metering_points = MeteringPoint.accessible_by_user(profile.user).where(*filter)
            total_pages    = metering_points.page(page).per_page(per_page).total_pages
            paginate(render(metering_points, meta: { total_pages: total_pages }))
          else
            status 403
          end
        end

      end
    end
  end
end
