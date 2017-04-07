require 'profile_resource'
module API
  module V1
    class Profiles < Grape::API
      include API::V1::Defaults
      resource :profiles do

        desc "Return all profiles"
        params do
          optional :order_direction, type: String, default: 'DESC', values: ['DESC', 'ASC'], desc: "Ascending Order and Descending Order"
          optional :order_by, type: String, default: 'created_at', values: ['user_name', 'first_name', 'last_name', 'created_at'], desc: "Order by Attribute"
        end
        oauth2 :full
        get do
          order = "#{permitted_params[:order_by]} #{permitted_params[:order_direction]}"
          Profile
            .anonymized_readable_by(current_user)
            .order(order)
        end


        desc "Return a Profile"
        params do
          requires :id, type: String, desc: "ID of the Profile"
        end
        oauth2 false
        get ":id" do
          profile = Profile.anonymized_guarded_retrieve(current_user, permitted_params)
          render(profile, meta: {
            updatable: profile.updatable_by?(current_user),
            deletable: profile.deletable_by?(current_user)
          })
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
        end
        oauth2 false
        get ':id/groups' do
          profile = Profile.guarded_retrieve(current_user, permitted_params)
          groups = Group::Base.accessible_by_user(profile.user)
          groups.readable_by(current_user)
        end


        desc 'Return profile friends'
        params do
          requires :id, type: String, desc: "ID of the Profile"
        end
        oauth2 false
        get ':id/friends' do
          profile = Profile.guarded_retrieve(current_user, permitted_params)
          profile.user.friends.readable_by(current_user)
        end

        desc 'Return profile registers'
        params do
          requires :id, type: String, desc: "ID of the Profile"
        end
        oauth2 false
        get ':id/registers' do
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
          Register::Base.accessible_by_user(profile.user).where(readable: types)
        end

      end
    end
  end
end
