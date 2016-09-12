module API
  module V1
    class Groups < Grape::API
      include API::V1::Defaults
      resource :groups do

        desc "Return all groups"
        params do
          optional :filter, type: String, desc: "Search query using #{Base.join(Group.search_attributes)}"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get do
          paginated_response(Group.filter(permitted_params[:filter])
                               .readable_by(current_user))
        end





        desc "Return a Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
        oauth2 false
        get ":id" do
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
          # TODO cleanup move logic into Group and ensure manager
          # and handle the ONE metering-point as validation error
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
          if group.deletable_by?(current_user)
            group.destroy
            status 204
          else
            status 403
          end
        end



        desc "Return the related metering-points for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get ":id/metering-points" do
          group = Group.find(permitted_params[:id])

          # metering_points do consider group relation for readable_by
          paginated_response(MeteringPoint.by_group(group).without_externals.anonymized_readable_by(current_user))
        end



        desc "Return the related managers for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :simple, :full
        get [':id/managers', ':id/relationships/managers'] do
          group = Group.find(permitted_params[:id])
          if group.readable_by?(current_user)
            paginated_response(group.managers.readable_by(current_user))
          else
            status 403
          end
        end


        desc 'Add user to group managers'
        params do
          requires :id, type: String, desc: "ID of the group"
          requires :data, type: Hash do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        post ':id/relationships/managers' do
          group           = Group.find(permitted_params[:id])
          user            = User.find(permitted_params[:data][:id])
          if group.updatable_by?(current_user)
            user.add_role(:manager, group)
            status 204
          else
            status 403
          end
        end

        desc 'Replace group managers'
        params do
          requires :id, type: String, desc: "ID of the group"
          requires :data, type: Array do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        patch ':id/relationships/managers' do
          group    = Group.find(permitted_params[:id])
          if group.updatable_by?(current_user, :replace_managers)
            ids = permitted_params[:data].collect{ |d| d[:id] }
            group.replace_managers(ids)
          else
            status 403
          end
        end

        desc 'Remove user from group managers'
        params do
          requires :id, type: String, desc: "ID of the group"
          requires :data, type: Hash do
            requires :id, type: String, desc: "ID of the user"
          end
        end
        oauth2 :full
        delete ':id/relationships/managers' do
          group           = Group.find(permitted_params[:id])
          user            = User.find(permitted_params[:data][:id])
          if group.updatable_by?(current_user, user)
            user.remove_role(:manager, group)
            status 204
          else
            status 403
          end
        end


        desc "Return the related members for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :simple, :full
        get [':id/members', ':id/relationships/members'] do
          group = Group.find(permitted_params[:id])
          if group.readable_by?(current_user)
            paginated_response(group.members.readable_by(current_user))
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
            group.energy_producers.readable_by(current_user)
          else
            status 403
          end
        end


        desc "Return the related energy-consumers for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
        oauth2 :simple, :full
        get ":id/energy-consumers" do
          group = Group.find(permitted_params[:id])
          if group.readable_by?(current_user)
            group.energy_consumers.readable_by(current_user)
          else
            status 403
          end
        end


        desc 'Return the related comments for Group'
        params do
          requires :id, type: String, desc: 'ID of the group'
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :simple, :full
        get ':id/comments' do
          group = Group.find(permitted_params[:id])
          if group.readable_by?(current_user)
            paginated_response(group.comment_threads.readable_by(current_user))
          else
            status 403
          end
        end




      end
    end
  end
end
