module API
  module V1
    class Users < Grape::API
      include API::V1::Defaults
      resource 'users' do

        desc "Return me"
        oauth2 :public, :full
        get "me" do
          current_user
        end

        desc "Return all Users"
        params do
          optional :filter, type: String, desc: "Search query using #{Base.join(User.search_attributes)}"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :full
        get do
          users = User.filter(permitted_params[:filter]).readable_by(current_user)
          paginated_response(users)
        end


        desc "Return a User"
        params do
          requires :id, type: String, desc: "ID of the user"
        end
        oauth2 :public, :full
        get ":id" do
          user = User.find(permitted_params[:id])
          if user.readable_by?(current_user)
            user
          else
            status 403
          end
        end


        desc "Create a User"
        params do
          requires :email, type: String
          requires :password, type: String
          requires :profile, type: Hash do
            requires :user_name, type: String
            requires :first_name, type: String
            requires :last_name, type: String
          end
        end
        oauth2 :full
        post do
          if User.creatable_by?(current_user)
            profile = Profile.new(permitted_params.delete(:profile))
            permitted_params[:profile] = profile
            user = User.create!(permitted_params)
            created_response(user)
          else
            status 403
          end
        end


        desc "Return the related groups for User"
        params do
          requires :id, type: String, desc: "ID of the profile"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :public, :full
        get ":id/groups" do
          user          = User.find(permitted_params[:id])
          groups        = Group.where(id: user.accessible_groups.map(&:id))
          per_page      = permitted_params[:per_page]
          page          = permitted_params[:page]
          total_pages   = groups.page(page).per_page(per_page).total_pages
          paginate(render(groups, meta: { total_pages: total_pages }))
        end



        desc "Return the related metering-points for User"
        params do
          requires :id, type: String, desc: "ID of the User"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :public, :full
        get ":id/metering-points" do
          user = User.find(permitted_params[:id])
          if user.readable_by?(current_user)
            # TODO MeteringPoint.readable_by(user, true).anonymized_readable_by(current_user)
            paginated_response(user.accessible_metering_points_relation)
          else
            status 403
          end
        end


        desc "Return the related meters for User"
        params do
          requires :id, type: String, desc: "ID of the User"
          optional :manufacturer_product_serialnumber, type: String, desc: "manufacturer product serialnumber"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :full, :smartmeter
        get ":id/meters" do
          user = User.find(permitted_params[:id])
          meters = Meter.with_role(:manager, user)
          if permitted_params[:manufacturer_product_serialnumber]
            meters = meters.where(manufacturer_product_serialnumber: permitted_params[:manufacturer_product_serialnumber])
          end
          paginated_response(meters)
        end


        desc "Return the related friends for User"
        params do
          requires :id, type: String, desc: "ID of the User"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :public, :full
        get ":id/friends" do
          user = User.find(permitted_params[:id])
          paginated_response(user.friends)
        end


        desc 'Return a friend'
        params do
          requires :id, type: String, desc: "ID of the User"
          requires :friend_id, type: String, desc: 'ID of the friend'
        end
        oauth2 :public
        get ':id/friends/:friend_id' do
          user = User.find(permitted_params[:id])
          if user.readable_by?(current_user)
            friend = user.friends.find(permitted_params[:friend_id])
            if friend.readable_by?(current_user)
              friend
            else
              status 403
            end
          else
            status 403
          end
        end


        desc 'Delete a friend'
        params do
          requires :id, type: String, desc: "ID of the User"
          requires :friend_id, type: String, desc: 'ID of the friend'
        end
        oauth2 :public, :full
        delete ':id/friends/:friend_id' do
          user = User.find(permitted_params[:id])
          if user.updatable_by?(current_user)
            friend = user.friends.find(permitted_params[:friend_id])
            user.friends.delete(friend)
            status 204
          else
            status 403
          end
        end


        desc 'List of received friendship requests'
        params do
          requires :id, type: String, desc: "ID of the User"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :public, :full
        get ':id/friendship-requests' do
          user = User.find(permitted_params[:id])
          if user.readable_by?(current_user)
            paginated_response(user.received_friendship_requests)
          else
            status 403
          end
        end


        desc 'Create friendship request'
        params do
          requires :id, type: String, desc: "ID of the User"
          requires :receiver_id, type: String, desc: 'ID of a receiver'
        end
        oauth2 :public, :full
        post ':id/friendship-requests' do
          user = User.find(permitted_params[:id])
          if user.updatable_by?(current_user)
            receiver  = User.find(permitted_params[:receiver_id])
            friendship_request = FriendshipRequest.new(sender: user, receiver: receiver)
            if friendship_request.save
              friendship_request.create_activity key: 'friendship_request.create', owner: user, recipient: receiver
            end
            created_response(friendship_request)
          else
            status 403
          end
        end


        desc 'Accept friendship request'
        params do
          requires :id, type: String, desc: "ID of the User"
          requires :request_id, type: String, desc: "ID of friendship request"
        end
        oauth2 :public, :full
        patch ':id/friendship-requests/:request_id' do
          user = User.find(permitted_params[:id])
          if user.updatable_by?(current_user)
            friendship_request = FriendshipRequest.where(receiver: user.id).find(permitted_params[:request_id])
            friendship_request.create_activity key: 'friendship.create', owner: current_user, recipient: friendship_request.sender
            friendship_request.accept
            status 204
          else
            status 403
          end
        end


        desc 'Reject friendship request'
        params do
          requires :id, type: String, desc: "ID of the User"
          requires :request_id, type: String, desc: "ID of friendship request"
        end
        oauth2 :public, :full
        delete ':id/friendship-requests/:request_id' do
          user = User.find(permitted_params[:id])
          if user.updatable_by?(current_user)
            friendship_request = FriendshipRequest.where(receiver: user.id).find(permitted_params[:request_id])
            friendship_request.create_activity key: 'friendship_request.reject', owner: current_user, recipient: friendship_request.sender
            friendship_request.reject
            status 204
          else
            status 403
          end
        end


        desc "Return the related devices for User"
        params do
          requires :id, type: String, desc: "ID of the User"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :public, :full
        get ":id/devices" do
          user = User.find(permitted_params[:id])
          if user.readable_by?(current_user)
            paginated_response(Device.with_role(:manager, user))
          else
            status 403
          end
        end


        desc 'Return user activities'
        params do
          requires :id, type: String, desc: "ID of the User"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :public, :full
        get ':id/activities' do
          user = User.find(permitted_params[:id])
          if user.readable_by?(current_user)
            paginated_response(PublicActivity::Activity.where({ owner_type: 'User', owner_id: permitted_params[:id] }))
          else
            status 204
          end
        end


      end
    end
  end
end
