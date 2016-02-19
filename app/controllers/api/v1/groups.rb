module API
  module V1
    class Groups < Grape::API
      include API::V1::Defaults
      resource :groups do



        desc "Return all groups"
        get "", root: :groups do
          group_ids = Group.where(readable: 'world').ids
          if current_user
            group_ids << Group.where(readable: 'community').ids
            group_ids << Group.with_role(:manager, current_user)
            current_user.friends.each do |friend|
              if friend
                Group.where(readable: 'friends').with_role(:manager, friend).each do |friend_group|
                  group_ids << friend_group.id
                end
              end
            end
          end
          return Group.where(id: group_ids)
        end





        desc "Return a Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
        get ":id", root: "group" do
          Group.where(id: permitted_params[:id]).first!
        end




        desc "Create a Group."
        params do
          requires :name,         type: String, desc: "Name of the Group."
          requires :description,  type: String, desc: "Description of the Group."
        end
        post do
          if Group.creatable_by?(current_user)
            @params = params.group || params
            @group = Group.new({
              name: @params.name,
              description: @params.description
              })

            if @group.save!
              current_user.add_role(:manager, @group)
              return @group
            end
          else
            error!('you need at least one out-metering_point', 401)
          end
        end



        desc "Update a Group."
        params do
          requires :id, type: String, desc: "Group ID."
          optional :name
        end
        put ':id' do
          @group = Group.find(params[:id])
          if @group.updatable_by?(current_user)
            @params = params.group || params
            @group.update({
                name:  @params.name,
                image: @params.image
              })

            return @group
          else
            status 403
          end
        end





        desc "Delete a Group."
        params do
          requires :id, type: String, desc: "Group ID"
        end
        delete ':id' do
          current_user.statuses.find(params[:id]).destroy
        end






        desc "Return the related metering-points for Group"
        params do
          requires :id, type: String, desc: "ID of the profile"
        end
        paginate(per_page: per_page=10)
        get ":id/metering-points" do
          @per_page     = params[:per_page] || per_page
          @page         = params[:page] || 1
          group         = Group.where(id: permitted_params[:id]).first!
          @total_pages  = group.metering_points.without_externals.page(@page).per(@per_page).total_pages
          paginate(render(group.metering_points.without_externals, meta: { total_pages: @total_pages }))
        end




        desc "Return the related devices for Group"
        params do
          requires :id, type: String, desc: "ID of the profile"
        end
        get ":id/devices" do
          group = Group.where(id: permitted_params[:id]).first!
          group.devices
        end



        desc "Return the related managers for Group"
        params do
          requires :id, type: String, desc: "ID of the profile"
        end
        get ":id/managers" do
          group = Group.where(id: permitted_params[:id]).first!
          group.managers
        end


        desc "Return the related energy-producers for Group"
        params do
          requires :id, type: String, desc: "ID of the profile"
        end
        get ":id/energy-producers" do
          group = Group.where(id: permitted_params[:id]).first!
          group.energy_producers
        end


        desc "Return the related energy-consumers for Group"
        params do
          requires :id, type: String, desc: "ID of the profile"
        end
        get ":id/energy-consumers" do
          group = Group.where(id: permitted_params[:id]).first!
          group.energy_consumers
        end




      end
    end
  end
end
