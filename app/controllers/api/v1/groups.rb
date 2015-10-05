module API
  module V1
    class Groups < Grape::API
      include API::V1::Defaults
      resource :groups do



        desc "Return all groups"
        get "", root: :groups do
          guard!
          if current_user
            Group.all
          else
            Group.where(readable: 'world')
          end
        end




        desc "Return a Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
        get ":id", root: "group" do
          guard!
          Group.where(id: permitted_params[:id]).first!
        end




        desc "Create a Group."
        params do
          requires :name,         type: String, desc: "Name of the Group."
          requires :description,  type: String, desc: "Description of the Group."
        end
        post do
          guard!
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
          guard!
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
          guard!
          current_user.statuses.find(params[:id]).destroy
        end





        desc "Return the related metering-points for Group"
        params do
          requires :id, type: String, desc: "ID of the profile"
        end
        get ":id/metering-points" do
          group = Group.where(id: permitted_params[:id]).first!
          group.metering_points
        end





      end
    end
  end
end
