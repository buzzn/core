module API
  module V1
    class Roles < Grape::API
      include API::V1::Defaults

      resource :roles do

        before do
          @permitted_resources  = ['MeteringPoint', 'Group']
          @permitted_roles      = ['member', 'manager']

          doorkeeper_authorize! :admin
        end

        desc 'Add a role'
        params do
          requires :resource_id,    type: String, desc: 'Resource id'
          requires :resource_type,  type: String, desc: 'Resource ClassName'
          requires :name,           type: String, desc: 'Role name'
          requires :user_id,        type: String, desc: 'User id'
        end
        post 'add' do
          if (@permitted_resources.include?(permitted_params[:resource_type]) &&
              @permitted_roles.include?(permitted_params[:name]))

            resource_class = Object.const_get(permitted_params[:resource_type])
            resource = resource_class.find(permitted_params[:resource_id])
            user = User.find(permitted_params[:user_id])
            user.add_role(permitted_params[:name], resource)
          else
            status 400
          end
        end

        desc 'Remove a role'
        params do
          requires :resource_id,    type: String, desc: 'Resource id'
          requires :resource_type,  type: String, desc: 'Resource ClassName'
          requires :name,           type: String, desc: 'Role name'
          requires :user_id,        type: String, desc: 'User id'
        end
        post 'remove' do
          if (@permitted_resources.include?(permitted_params[:resource_type]) &&
              @permitted_roles.include?(permitted_params[:name]))

            resource_class = Object.const_get(permitted_params[:resource_type])
            resource = resource_class.find(permitted_params[:resource_id])
            user = User.find(permitted_params[:user_id])
            user.remove_role(permitted_params[:name], resource)
          else
            status 400
          end
        end
      end
    end
  end
end