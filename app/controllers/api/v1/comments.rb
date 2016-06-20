module API
  module V1
    class Comments < Grape::API
      include API::V1::Defaults
      resource :comments do


        desc 'Return usernames by ids'
        params do
          requires :ids, type: Array, desc: 'User ids from comment(s)'
        end
        get 'usernames' do
          # TODO: place some limiting here
          users = User.find(permitted_params[:ids])
          names = {}
          users.select do |user|
            if user.profile.readable_by_world? || (current_user && user.profile.readable_by?(current_user))
              names[user.id] = user.profile.name
            else
              # TODO: i18n
              names[user.id] = 'Hidden'
            end
          end
          names
        end


      end
    end
  end
end
