module API
  module V1
    class Users < Grape::API
      include API::V1::Defaults
      resource 'users' do

        desc "Return me"
        get "me" do
          if current_user.nil?
            raise Buzzn::PermissionDenied.create(User, :retrieve, nil)
          end
          # use the normal loading semantic to produce consistent results
          UserSingleResource.retrieve(current_user, current_user.id)
        end

        desc "Return all Users"
        params do
          optional :filter, type: String, desc: "Search query using #{Base.join(User.search_attributes)}"
        end
        get do
          UserResource.all(current_user, permitted_params[:filter])
        end


        desc "Return a User"
        params do
          requires :id, type: String, desc: "ID of the user"
        end
        get ":id" do
          UserSingleResource.retrieve(current_user, permitted_params)
        end


        desc "Return the related profile for User"
        params do
          requires :id, type: String, desc: "ID of the user"
        end
        get ":id/profile" do
          UserResource.retrieve(current_user, permitted_params)
            .profile
        end


        desc 'Return the related bank_account for User'
        params do
          requires :id, type: String, desc: 'ID of the User'
        end
        get ':id/bank-account' do
          UserResource
            .retrieve(current_user, permitted_params)
            .bank_account!
        end


        desc "Return the related meters for User"
        params do
          requires :id, type: String, desc: "ID of the User"
          optional :filter, type: String, desc: "Search query using #{Base.join(Meter::Base.search_attributes)}"
        end
        get ":id/meters" do
          UserResource
            .retrieve(current_user, permitted_params)
            .meters(permitted_params[:filter])
        end
      end
    end
  end
end
