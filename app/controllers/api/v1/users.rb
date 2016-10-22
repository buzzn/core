module API
  module V1
    class Users < Grape::API
      include API::V1::Defaults
      resource 'users' do

        desc "Return me"
        oauth2 :simple, :full, :smartmeter
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
          users = User.filter(permitted_params[:filter])
          paginated_response(users.readable_by(current_user))
        end


        desc "Return a User"
        params do
          requires :id, type: String, desc: "ID of the user"
        end
        oauth2 :simple, :full
        get ":id" do
          User.guarded_retrieve(current_user, permitted_params)
        end


        desc "Create a User"
        params do
          requires :email, type: String, desc: 'email'
          requires :password, type: String, desc: 'password'
          requires :profile, type: Hash do
            requires :user_name, type: String, desc: 'username'
            requires :first_name, type: String, desc: 'first-name'
            requires :last_name, type: String, desc: 'last-name'
          end
        end
        oauth2 false
        post do
          profile = Profile.new(permitted_params.delete(:profile))
          permitted_params[:profile] = profile
          user = User.guarded_create(current_user, permitted_params)
          created_response(user)
        end

        desc "Return the related profile for User"
        params do
          requires :id, type: String, desc: "ID of the user"
        end
        oauth2 :simple, :full
        get ":id/profile" do
          user = User.guarded_retrieve(current_user, permitted_params)
          user.profile.guarded_read(current_user)
        end


        desc "Return the related groups for User"
        params do
          requires :id, type: String, desc: "ID of the profile"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :simple, :full
        get ":id/groups" do
          user   = User.guarded_retrieve(current_user, permitted_params)
          groups = Group.accessible_by_user(user)
          paginated_response(groups.readable_by(current_user))
        end



        desc "Return the related metering-points for User"
        params do
          requires :id, type: String, desc: "ID of the User"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :simple, :full
        get ":id/metering-points" do
          user = User.guarded_retrieve(current_user, permitted_params)
          metering_points = MeteringPoint.accessible_by_user(user)
          paginated_response(metering_points.anonymized_readable_by(current_user))
        end


        desc "Return the related meters for User"
        params do
          requires :id, type: String, desc: "ID of the User"
          optional :filter, type: String, desc: "Search query using #{Base.join(Meter.search_attributes)}"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :full, :smartmeter
        get ":id/meters" do
          user = User.guarded_retrieve(current_user, permitted_params)
          meters = Meter.filter(permitted_params[:filter]).accessible_by_user(user)
          paginated_response(meters.readable_by(current_user))
        end


        desc "Return the related friends for User"
        params do
          requires :id, type: String, desc: "ID of the User"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :simple, :full
        get [':id/friends', ':id/relationships/friends'] do
          user = User.guarded_retrieve(current_user, permitted_params)
          paginated_response(user.friends.readable_by(current_user))
        end


        desc 'Return a friend'
        params do
          requires :id, type: String, desc: "ID of the User"
          requires :friend_id, type: String, desc: 'ID of the friend'
        end
        oauth2 :simple, :full
        get ':id/friends/:friend_id' do
          user = User.guarded_retrieve(current_user, permitted_params)
          friend = user.friends.find(permitted_params[:friend_id])
          friend.guarded_read(current_user)
        end


        desc 'Delete a friend'
        params do
          requires :id, type: String, desc: "ID of the User"
          requires :data, type: Hash do
            requires :id, type: String, desc: 'ID of the friend'
          end
        end
        oauth2 :full
        delete ':id/relationships/friends' do
          user = User.guarded_retrieve(current_user, permitted_params)
          if user.updatable_by?(current_user)
            friend = user.friends.find(permitted_params[:data][:id])
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
        oauth2 :simple, :full
        get [':id/friendship-requests',
             ':id/relationships/friendship-requests'] do
          user = User.guarded_retrieve(current_user, permitted_params)
          # TODO readable_by
          paginated_response(user.received_friendship_requests)
        end


        desc 'Create friendship request'
        params do
          requires :id, type: String, desc: "ID of the User"
          requires :data, type: Hash do
            requires :id, type: String, desc: "ID of friendship request"
          end
        end
        oauth2 :simple, :full
        post ':id/relationships/friendship-requests' do
          user = User.guarded_retrieve(current_user, permitted_params)
          if user.updatable_by?(current_user)
            # TODO really unguarded ?
            receiver  = User.unguarded_retrieve(permitted_params[:data][:id])
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
        oauth2 :simple, :full
        post ':id/friendship-requests/:request_id' do
          user = User.guarded_retrieve(current_user, permitted_params)
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
          requires :data, type: Hash do
            requires :id, type: String, desc: "ID of friendship request"
          end
        end
        oauth2 :simple, :full
        delete ':id/relationships/friendship-requests' do
          user = User.guarded_retrieve(current_user, permitted_params)
          if user.updatable_by?(current_user)
            friendship_request = FriendshipRequest.where(receiver: user.id).find(permitted_params[:data][:id])
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
        oauth2 :simple, :full
        get ":id/devices" do
          user = User.guarded_retrieve(current_user, permitted_params)
          devices = Device.accessible_by_user(user).readable_by(current_user)
          paginated_response(devices)
        end


        desc 'Return user activities'
        params do
          requires :id, type: String, desc: "ID of the User"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :simple, :full
        get ':id/activities' do
          user = User.guarded_retrieve(current_user, permitted_params)
          # TODO readable_by
          paginated_response(PublicActivity::Activity.where({ owner_type: 'User', owner_id: permitted_params[:id] }))
        end


      end
    end
  end
end
