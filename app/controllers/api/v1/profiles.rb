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
          paginated_response(Profile.anonymized_readable_by(current_user))
        end


        desc "Return a Profile"
        params do
          requires :id, type: String, desc: "ID of the Profile"
        end
        oauth2 false
        get ":id" do
          Profile.anonymized_get(permitted_params[:id], current_user) ||
            status(403)
        end


        desc "Create a Profile"
        params do
          requires :user_name, type: String
          requires :first_name, type: String
          requires :last_name, type: String
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
            groups = Group.accessible_by_user(profile.user)
            paginated_response(groups.readable_by(current_user))
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
          # we need to check the profile before filtering the friends
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
            # TODO move this permission logic into Authority
            # this does not match the Authority for readable_by? and should be:
            # `accessible_by_user(profile.user).readable_by?(current_user)`
            # maybe it is just adjusting the test
            paginated_response(MeteringPoint.accessible_by_user(profile.user).where(readable: types))
          else
            status 403
          end
        end

      end
    end
  end
end
