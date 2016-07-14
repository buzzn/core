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
          optional :first_name, type: String, desc: "Firstname of the user"
          optional :last_name, type: String, desc: "Lastname of the user"
          optional :group_name, type: String, desc: "Group name to which the user belongs"
        end
        paginate(per_page: per_page=10)
        oauth2 :full
        get do
          per_page         = params[:per_page] || per_page
          page             = params[:page] || 1

          ids = User.filter(params.slice(:first_name, :last_name, :group_name)).select do |obj|
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
        oauth2 :public
        get ":id/metering-points" do
          user = User.find(params[:id])
          user.accessible_metering_points
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
          user.friends.find(params[:friend_id])
        end


        desc 'Delete a friend'
        oauth2 :public, :full
        delete ':id/friends/:friend_id' do
          if current_user.id == params[:id]
            user    = User.find(params[:id])
            friend  = user.friends.find(params[:friend_id])
            user.friends.delete(friend) if friend
          else
            status 403
          end
        end


        desc 'List of received friendship requests'
        oauth2 :public, :full
        get ':id/friendship-requests' do
          if current_user.id == params[:id]
            User.find(params[:id]).received_friendship_requests
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
          if current_user.id == params[:id]
            sender    = User.find(params[:id])
            receiver  = User.find(params[:receiver_id])
            friendship_request = FriendshipRequest.new(sender: sender, receiver: receiver)
            if friendship_request.save
              friendship_request.create_activity key: 'friendship_request.create', owner: sender, recipient: receiver
            end
          else
            status 403
          end
        end


        desc 'Accept friendship request'
        oauth2 :public, :full
        put ':id/friendship-requests/:request_id' do
          if current_user.id == params[:id]
            friendship_request = FriendshipRequest.where(receiver: params[:id]).find(params[:request_id])
            friendship_request.create_activity key: 'friendship.create', owner: current_user, recipient: friendship_request.sender
            friendship_request.accept
          else
            status 403
          end
        end


        desc 'Reject friendship request'
        oauth2 :public, :full
        delete ':id/friendship-requests/:request_id' do
          if current_user.id == params[:id]
            friendship_request = FriendshipRequest.where(receiver: params[:id]).find(params[:request_id])
            friendship_request.create_activity key: 'friendship_request.reject', owner: current_user, recipient: friendship_request.sender
            friendship_request.reject
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
          @per_page     = params[:per_page] || per_page
          @page         = params[:page] || 1
          @total_pages  = Device.with_role(:manager, user).page(@page).per_page(@per_page).total_pages
          paginate(render(Device.with_role(:manager, user), meta: { total_pages: @total_pages }))
        end


        desc 'Return user activities'
        oauth2 :public, :full
        get ':id/activities' do
          PublicActivity::Activity.where({ owner_type: 'User', owner_id: params[:id] })
        end


      end
    end
  end
end
