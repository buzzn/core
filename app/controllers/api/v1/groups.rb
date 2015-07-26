module API
  module V1
    class Groups < Grape::API
      include API::V1::Defaults
      resource :groups do


        desc "Return all groups"
        get "", root: :groups do
          Group.all
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
          guard!
          group = Group.new({ name: params[:name], description: params[:description]})
          if group.save!
            current_user.add_role(:manager, group)
            return todo_list
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

            @group.update({
                name: params.group.name,
                image: params.group.image
              })

            return @group
          else
            status 403
          end

        end



      end
    end
  end
end
