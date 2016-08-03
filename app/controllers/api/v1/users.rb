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
          optional :search, type: String, desc: "Search query using #{Base.join(User.search_attributes)}"
        end
        paginate(per_page: per_page=10)
        oauth2 :full
        get do
          per_page         = params[:per_page] || per_page
          page             = params[:page] || 1
          ids = User.filter(params[:search]).select do |obj|
            obj.readable_by?(current_user)
          end.collect { |obj| obj.id }
          users = User.where(id: ids)
          total_pages  = users.page(page).per_page(per_page).total_pages
          paginate(render(users, meta: { total_pages: total_pages }))
        end


        desc "Return a User"
        params do
          requires :id, type: String, desc: "ID of the user"
        end
        oauth2 :public, :full
        get ":id" do
          user = User.find(params[:id])
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
          requires :first_name, type: String
          requires :last_name, type: String
        end
        oauth2 :full
        post do
          if User.creatable_by?(current_user)
            User.create!(
              email:    params[:email],
              password: params[:password],
              profile:  Profile.new( user_name: params[:user_name], first_name: params[:first_name], last_name:  params[:last_name] )
            )
          else
            status 403
          end
        end


        desc "Return the related groups for User"
        params do
          requires :id, type: String, desc: "ID of the profile"
        end
        paginate(per_page: per_page=10)
        oauth2 :public, :full
        get ":id/groups" do
          user          = User.find(params[:id])
          groups        = Group.where(id: user.accessible_groups.map(&:id))
          @per_page     = params[:per_page] || per_page
          @page         = params[:page] || 1
          @total_pages  = groups.page(@page).per_page(@per_page).total_pages
          paginate(render(groups, meta: { total_pages: @total_pages }))
        end



        desc "Return the related metering-points for User"
        params do
          requires :id, type: String, desc: "ID of the User"
        end
        paginate(per_page: per_page=10)
        oauth2 :public, :full
        get ":id/metering-points" do
          user = User.find(params[:id])
          if user.readable_by?(current_user)
            user.accessible_metering_points
          else
            status 403
          end
        end


        desc "Return the related meters for User"
        params do
          requires :id, type: String, desc: "ID of the User"
          optional :manufacturer_product_serialnumber, type: String, desc: "manufacturer product serialnumber"
        end
        paginate(per_page: per_page=10)
        oauth2 :full
        get ":id/meters" do
          user = User.find(params[:id])
          if params[:manufacturer_product_serialnumber]
            meters = Meter.with_role(:manager, user).where(manufacturer_product_serialnumber: params[:manufacturer_product_serialnumber])
          else
            meters = Meter.with_role(:manager, user)
          end
          @per_page     = params[:per_page] || per_page
          @page         = params[:page] || 1
          @total_pages  = meters.page(@page).per_page(@per_page).total_pages
          paginate(render(meters, meta: { total_pages: @total_pages }))
        end


        desc "Return the related friends for User"
        params do
          requires :id, type: String, desc: "ID of the User"
        end
        paginate(per_page: per_page=10)
        oauth2 :public, :full
        get ":id/friends" do
          user = User.find(params[:id])
          @per_page     = params[:per_page] || per_page
          @page         = params[:page] || 1
          @total_pages  = user.friends.page(@page).per_page(@per_page).total_pages
          paginate(render(user.friends, meta: { total_pages: @total_pages }))
        end


        desc 'Return a friend'
        oauth2 :public
        get ':id/friends/:friend_id' do
          user = User.find(params[:id])
          if user.readable_by?(current_user)
            friend = user.friends.find(params[:friend_id])
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
        oauth2 :public, :full
        delete ':id/friends/:friend_id' do
          user = User.find(params[:id])
          if user.updatable_by?(current_user)
            friend = user.friends.find(params[:friend_id])
            user.friends.delete(friend)
            status 204
          else
            status 403
          end
        end


        desc 'List of received friendship requests'
        oauth2 :public, :full
        get ':id/friendship-requests' do
          user = User.find(params[:id])
          if user.readable_by?(current_user)
            # TODO paginate
            user.received_friendship_requests
          else
            status 403
          end
        end


        desc 'Create friendship request'
        params do
          requires :receiver_id, type: String, desc: 'ID of a receiver'
        end
        oauth2 :public, :full
        post ':id/friendship-requests' do
          user = User.find(params[:id])
          if user.updatable_by?(current_user)
            receiver  = User.find(params[:receiver_id])
            friendship_request = FriendshipRequest.new(sender: user, receiver: receiver)
            if friendship_request.save
              friendship_request.create_activity key: 'friendship_request.create', owner: user, recipient: receiver
            end
            friendship_request
          else
            status 403
          end
        end


        desc 'Accept friendship request'
        oauth2 :public, :full
        patch ':id/friendship-requests/:request_id' do
          user = User.find(params[:id])
          if user.updatable_by?(current_user)
            friendship_request = FriendshipRequest.where(receiver: user.id).find(params[:request_id])
            friendship_request.create_activity key: 'friendship.create', owner: current_user, recipient: friendship_request.sender
            friendship_request.accept
            status 204
          else
            status 403
          end
        end


        desc 'Reject friendship request'
        oauth2 :public, :full
        delete ':id/friendship-requests/:request_id' do
          user = User.find(params[:id])
          if user.updatable_by?(current_user)
            friendship_request = FriendshipRequest.where(receiver: user.id).find(params[:request_id])
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
        end
        paginate(per_page: per_page=10)
        oauth2 :public, :full
        get ":id/devices" do
          user = User.find(params[:id])
          if user.readable_by?(current_user)
            @per_page     = params[:per_page] || per_page
            @page         = params[:page] || 1
            @total_pages  = Device.with_role(:manager, user).page(@page).per_page(@per_page).total_pages
            paginate(render(Device.with_role(:manager, user), meta: { total_pages: @total_pages }))
          else
            status 403
          end
        end


        desc 'Return user activities'
        oauth2 :public, :full
        get ':id/activities' do
          user = User.find(params[:id])
          if user.readable_by?(current_user)
            # TODO paginate
            PublicActivity::Activity.where({ owner_type: 'User', owner_id: params[:id] })
          else
            status 204
          end
        end


      end
    end
  end
end
