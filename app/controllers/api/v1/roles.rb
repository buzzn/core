module API
  module V1
    class Roles < Grape::API
      include API::V1::Defaults

      resource :roles do

        desc 'Add a role'
        params do
        end
        post 'add' do
        end

      end
    end
  end
end