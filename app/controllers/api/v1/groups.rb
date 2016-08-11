module API
  module V1
    class Groups < Grape::API
      include API::V1::Defaults
      resource :groups do

        desc "Return all groups"
        params do
          optional :filter, type: String, desc: "Search query using #{Base.join(Group.search_attributes)}"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get root: :groups do
          group_ids = Group.filter(permitted_params[:filter]).where(readable: 'world').ids
          if current_user
            group_ids << Group.filter(permitted_params[:filter]).where(readable: 'community').ids
            group_ids << Group.filter(permitted_params[:filter]).with_role(:manager, current_user)
            current_user.friends.each do |friend|
              if friend
                Group.filter(permitted_params[:filter]).where(readable: 'friends').with_role(:manager, friend).each do |friend_group|
                  group_ids << friend_group.id
                end
              end
            end
          end
          per_page     = permitted_params[:per_page]
          page         = permitted_params[:page]
          total_pages  = Group.where(id: group_ids.flatten).page(page).per_page(per_page).total_pages
          paginate(render(Group.where(id: group_ids.flatten), meta: { total_pages: total_pages }))
        end





        desc "Return a Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
        oauth2 false
        get ":id", root: "group" do
          group = Group.find(permitted_params[:id])
          if group.readable_by?(current_user)
            group
          else
            status 403
          end
        end




        desc "Create a Group."
        params do
          requires :name,         type: String, desc: "Name of the Group."
          requires :description,  type: String, desc: "Description of the Group."
        end
        oauth2 :full
        post do
          if Group.creatable_by?(current_user)
            group = Group.create!(permitted_params)
            current_user.add_role(:manager, group)
            created_response(group)
          else
            error!('you need at least one out-metering_point', 401)
          end
        end



        desc "Update a Group."
        params do
          requires :id, type: String, desc: "Group ID."
          optional :name
        end
        oauth2 :full
        patch ':id' do
          group = Group.find(permitted_params[:id])
          if group.updatable_by?(current_user)
            group.update!(permitted_params)
            group
          else
            status 403
          end
        end



        desc 'Delete a Group.'
        params do
          requires :id, type: String, desc: "Group ID"
        end
        oauth2 :full
        delete ':id' do
          group = Group.find(permitted_params[:id])
          if group.updatable_by?(current_user)
            group.destroy
            status 204
          else
            status 403
          end
        end



        desc "Return the related metering-points for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get ":id/metering-points" do
          group = Group.find(permitted_params[:id])

          if group.readable_by?(current_user)
            per_page        = permitted_params[:per_page]
            page            = permitted_params[:page]
            metering_points = MeteringPoint.by_group(group).without_externals
            total_pages     = metering_points.page(page).per_page(per_page).total_pages
            paginate(render(metering_points, meta: { total_pages: total_pages }))
          else
            status 403
          end
        end



        desc "Return the related managers for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :public, :full
        get ":id/managers" do
          group = Group.find(permitted_params[:id])
          if group.readable_by?(current_user)
            per_page     = permitted_params[:per_page]
            page         = permitted_params[:page]
            total_pages  = group.managers.page(page).per_page(per_page).total_pages
            paginate(render(group.managers, meta: { total_pages: total_pages }))
          else
            status 403
          end
        end


        desc 'Add user to group managers'
        params do
          requires :id, type: String, desc: "ID of the group"
          requires :user_id, type: String, desc: 'User id'
        end
        oauth2 :full
        post ':id/managers' do
          group           = Group.find(permitted_params[:id])
          user            = User.find(permitted_params[:user_id])
          if current_user.has_role?(:manager, group) || current_user.has_role?(:admin)
            user.add_role(:manager, group)
            status 204
          else
            status 403
          end
        end


        desc 'Remove user from group managers'
        params do
          requires :id, type: String, desc: "ID of the group"
          requires :user_id, type: String, desc: 'User id'
        end
        oauth2 :full
        delete ':id/managers/:user_id' do
          group           = Group.find(permitted_params[:id])
          user            = User.find(permitted_params[:user_id])
          if current_user.id == user.id || current_user.has_role?(:admin)
            user.remove_role(:manager, group)
            status 204
          else
            status 403
          end
        end


        desc "Return the related members for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :public, :full
        get ":id/members" do
          group           = Group.find(permitted_params[:id])
          if group.readable_by?(current_user)
            per_page     = permitted_params[:per_page]
            page         = permitted_params[:page]
            members      = group.members
            total_pages  = members.page(page).per_page(per_page).total_pages
            paginate(render(members, meta: { total_pages: total_pages }))
          else
            status 403
          end
        end


        desc "Return the related energy-producers for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
        oauth2 false
        get ":id/energy-producers" do
          group = Group.find(permitted_params[:id])
          if group.readable_by?(current_user)
            group.energy_producers
          else
            status 403
          end
        end


        desc "Return the related energy-consumers for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
        oauth2 :public, :full
        get ":id/energy-consumers" do
          group = Group.find(permitted_params[:id])
          if group.readable_by?(current_user)
            group.energy_consumers
          else
            status 403
          end
        end


        desc 'Return the related comments for Group'
        params do
          requires :id, type: String, desc: 'ID of the group'
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :public, :full
        get ':id/comments' do
          group = Group.find(permitted_params[:id])
          if group.readable_by?(current_user)
            per_page     = permitted_params[:per_page]
            page         = permitted_params[:page]
            total_pages  = group.comment_threads.page(page).per_page(per_page).total_pages
            paginate(render(group.comment_threads, meta: { total_pages: total_pages }))
          else
            status 403
          end
        end




      end
    end
  end
end
