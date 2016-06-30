module API
  module V1
    class Roles < Grape::API
      include API::V1::Defaults
      resource :roles do

        before do
          doorkeeper_authorize! :public
        end

        desc 'Add role to user for resource'
        params do
          requires :resource_id,    type: String, desc: 'Resource id'
          requires :resource_type,  type: String, desc: 'Resource ClassName', values: ['MeteringPoint', 'Group']
          requires :role,           type: String, desc: 'Role name', values: ['member', 'manager']
          requires :user_id,        type: String, desc: 'User id'
        end
        put 'add' do
          resource_class  = Object.const_get(permitted_params[:resource_type])
          resource        = resource_class.find(permitted_params[:resource_id])
          user            = User.find(permitted_params[:user_id])
          is_member       = false
          if permitted_params[:resource_type] == 'MeteringPoint'
            is_member     = current_user.has_role?(:member, resource)
          elsif permitted_params[:resource_type] == 'Group'
            is_member     = !!resource.members.index { |m| m.id == current_user.id }
          end

          if (current_user.has_role?(:manager, resource) ||
              permitted_params[:role] == 'member' && is_member ||
              current_user.has_role?(:admin))

            user.add_role(permitted_params[:role], resource)
          else
            status 403
          end
        end

        desc 'Remove role from user for resource'
        params do
          # maybe it's better not to provide role_id at all, but provide resource_id,
          # resource_class and role_name, because it's easier to get them at the frontend
          requires :role_id,        type: String, desc: 'Role id'
          requires :user_id,        type: String, desc: 'User id'
        end
        put 'remove' do
          role            = Role.find(permitted_params[:role_id])
          user            = User.find(permitted_params[:user_id])
          resource_class  = Object.const_get(role.resource_type)
          resource        = resource_class.find(role.resource_id)

          if (current_user.has_role?(:manager, resource) && role.name == 'member' ||
              current_user.id == user.id ||
              current_user.has_role?(:admin))

            user.remove_role(role.name, resource)
          else
            status 403
          end

        end

      end
    end
  end
end