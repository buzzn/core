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
          Profile.anonymized_guarded_retrieve(current_user, permitted_params)
        end


        desc "Create a Profile"
        params do
          requires :user_name, type: String, desc: 'username'
          requires :first_name, type: String, desc: 'first name'
          requires :last_name, type: String, desc: 'last name'
          optional :title, type: String, desc: 'title'
          optional :about_me, type: String, desc: 'about me'
          optional :website, type: String, desc: 'personal website'
          optional :facebook, type: String, desc: 'facebook profile url'
          optional :twitter, type: String, desc: 'twitter profle url'
          optional :xing, type: String, desc: 'xing profile url'
          optional :linkedin, type: String, desc: 'linkedin profile url'
          optional :gender, type: String, values: Profile.genders.map(&:to_s), desc: 'gender'
          optional :phone, type: String, desc: 'phone'
        end
        oauth2 :simple, :full
        post do
          profile = Profile.guarded_create(current_user, permitted_params)
          created_response(profile)
        end


        desc "Update a Profile"
        params do
          requires :id, type: String, desc: 'ID of the Profile'
          optional :user_name, type: String, desc: 'username'
          optional :first_name, type: String, desc: 'first name'
          optional :last_name, type: String, desc: 'last name'
          optional :title, type: String, desc: 'title'
          optional :about_me, type: String, desc: 'about me'
          optional :website, type: String, desc: 'personal website'
          optional :facebook, type: String, desc: 'facebook profile url'
          optional :twitter, type: String, desc: 'twitter profle url'
          optional :xing, type: String, desc: 'xing profile url'
          optional :linkedin, type: String, desc: 'linkedin profile url'
          optional :gender, type: String, values: Profile.genders.map(&:to_s), desc: 'gender'
          optional :phone, type: String, desc: 'phone'
        end
        oauth2 :simple, :full
        patch ':id' do
          profile = Profile.guarded_retrieve(current_user, permitted_params)
          profile.guarded_update(current_user, permitted_params)
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
          profile = Profile.guarded_retrieve(current_user, permitted_params)
          groups = Group.accessible_by_user(profile.user)
          paginated_response(groups.readable_by(current_user))
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
          profile = Profile.guarded_retrieve(current_user, permitted_params)
          paginated_response(profile.user.friends.readable_by(current_user))
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
          profile = Profile.guarded_retrieve(current_user, permitted_params)
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
        end

      end
    end
  end
end
