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
          paginated_response(Profile.readable_by(current_user))
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
          optional :title, type: String
          optional :about_me, type: String
          optional :website, type: String
          optional :facebook, type: String
          optional :twitter, type: String
          optional :xing, type: String
          optional :linkedin, type: String
          optional :gender, type: String, values: Profile.genders.map(&:to_s)
          optional :phone, type: String
        end
        oauth2 :simple, :full
        post do
          if Profile.creatable_by?(current_user)
            profile = Profile.create!(permitted_params)
            created_response(profile)
          else
            status 403
          end
        end


        desc "Update a Profile"
        params do
          requires :id, type: String, desc: 'ID of the Profile'
          requires :user_name, type: String
          requires :first_name, type: String
          requires :last_name, type: String
          optional :title, type: String
          optional :about_me, type: String
          optional :website, type: String
          optional :facebook, type: String
          optional :twitter, type: String
          optional :xing, type: String
          optional :linkedin, type: String
          optional :gender, type: String, values: Profile.genders.map(&:to_s)
          optional :phone, type: String
        end
        oauth2 :simple, :full
        patch ':id' do
          profile = Profile.find(permitted_params[:id])
          if profile.updatable_by?(current_user)
            profile.update!(permitted_params)
            profile
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
            user     = profile.user
            if current_user.nil?
              filter = [ 'groups.readable = ?', 'world' ]
            elsif current_user.friend?(user)
              filter = [ 'groups.readable != ?', 'members' ]
            else
              filter = [ 'groups.readable NOT IN (?)', ['friends', 'members'] ]
            end
            groups   = user.accessible_groups_relation.where(*filter)
            paginated_response(groups)
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
            paginated_response(profile.user.friends.readable_by(current_user))
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
          profile = Profile.find(permitted_params[:id])

          if profile.readable_by?(current_user)
            types = []
            if profile.readable_by_world?
              types << 'world'
            end
            if current_user
              types << 'community'
              if current_user.friend?(profile.user)
                types << 'friends'
              end
            end
            # TODO
            # this does not match the Authority for readable_by? and should be:
            # `accessible_by_user(profile.user).readable_by?(current_user)`
            paginated_response(MeteringPoint.accessible_by_user(profile.user).where(readable: types))
          else
            status 403
          end
        end

      end
    end
  end
end
