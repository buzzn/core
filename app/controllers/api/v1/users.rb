module API
  module V1
    class Users < Grape::API
      include API::V1::Defaults
      resource 'users' do

        desc "Return me"
        oauth2 :simple, :full, :smartmeter
        get "me" do
          # obey the loading semantic even if this is a bit of overkill here
          FullUserResource.retrieve(current_user, current_user.id)
        end

        desc "Return all Users"
        params do
          optional :filter, type: String, desc: "Search query using #{Base.join(User.search_attributes)}"
        end
        oauth2 :full
        get do
          UserResource.all(current_user, permitted_params[:filter])
        end


        desc "Return a User"
        params do
          requires :id, type: String, desc: "ID of the user"
        end
        oauth2 :simple, :full
        get ":id" do
          FullUserResource.retrieve(current_user, permitted_params)
        end


        desc "Return the related profile for User"
        params do
          requires :id, type: String, desc: "ID of the user"
        end
        oauth2 :simple, :full
        get ":id/profile" do
          UserResource.retrieve(current_user, permitted_params)
            .profile
        end


        desc 'Return the related bank_account for User'
        params do
          requires :id, type: String, desc: 'ID of the User'
        end
        oauth2 :full
        get ':id/bank-account' do
          UserResource
            .retrieve(current_user, permitted_params)
            .bank_account!
        end


        desc "Return the related meters for User"
        params do
          requires :id, type: String, desc: "ID of the User"
          optional :filter, type: String, desc: "Search query using #{Base.join(Meter::Base.search_attributes)}"
          optional :order_direction, type: String, default: 'DESC', values: ['DESC', 'ASC'], desc: "Ascending Order and Descending Order"
          optional :order_by, type: String, default: 'created_at', values: ['updated_at', 'created_at'], desc: "Order by Attribute"
        end
        oauth2 :full, :smartmeter
        get ":id/meters" do
          user = User.guarded_retrieve(current_user, permitted_params)
          meters = Meter::Base.filter(permitted_params[:filter]).accessible_by_user(user)
          order = "#{permitted_params[:order_by]} #{permitted_params[:order_direction]}"
          meters
            .readable_by(current_user)
            .order(order)
        end
      end
    end
  end
end
