module API
  module V1
    class Groups < Grape::API
      include API::V1::Defaults



      resource :tribes do
        desc "Create a Tribe"
        params do
          requires :name,         type: String, desc: "Name of the Tribe"
          requires :description,  type: String, desc: "Description of the Tribe"
        end
        oauth2 :full
        post do
          group = Group::Tribe.guarded_create(current_user, permitted_params)
          created_response(group)
        end
      end



      resource :groups do

        desc "Return all groups"
        params do
          optional :filter, type: String, desc: "Search query using #{Base.join(Group::Base.search_attributes)}"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
          optional :order_direction, type: String, default: 'DESC', values: ['DESC', 'ASC'], desc: "Ascending Order and Descending Order"
          optional :order_by, type: String, default: 'created_at', values: ['name', 'updated_at', 'created_at'], desc: "Order by Attribute"
        end
        paginate
        oauth2 false
        get do
          order = "#{permitted_params[:order_by]} #{permitted_params[:order_direction]}"
          paginated_response(
            Group::Base
              .filter(permitted_params[:filter])
              .readable_by(current_user)
              .order(order)
          )
        end



        desc "Return a Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
        oauth2 false
        get ":id" do
          group = Group::Base.guarded_retrieve(current_user, permitted_params)
          render(group, meta: {
            updatable: group.updatable_by?(current_user),
            deletable: group.deletable_by?(current_user)
          })
        end







        desc "Update a Group"
        params do
          requires :id, type: String, desc: "Group ID."
          optional :name
        end
        oauth2 :full
        patch ':id' do
          group = Group::Base.guarded_retrieve(current_user, permitted_params)
          group.guarded_update(current_user, permitted_params)
        end



        desc 'Delete a Group'
        params do
          requires :id, type: String, desc: "Group ID"
        end
        oauth2 :full
        delete ':id' do
          group = Group::Base.guarded_retrieve(current_user, permitted_params)
          deleted_response(group.guarded_delete(current_user))
        end



        desc "Return the related registers for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get ":id/registers" do
          group = Group::Base.guarded_retrieve(current_user, permitted_params)

          # registers do consider group relation for readable_by
          # TODO not clear why noe group.registers.without_externals ???
          paginated_response(Register::Base.by_group(group).without_externals.anonymized_readable_by(current_user).order(type: :desc)) # the order is to make sure we the Register::Virtual as first element as its attribute set is enough for even Input and Output Registers
        end


        desc "Return the related scores for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
          requires :interval, type: Symbol, values: [:day, :month, :year]
          requires :timestamp, type: DateTime
          optional :mode, type: Symbol, values: [:sufficiency, :closeness, :autarchy, :fitting]
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 false
        get ":id/scores" do
          group = Group::Base.guarded_retrieve(current_user, permitted_params)
          interval = permitted_params[:interval]
          timestamp = permitted_params[:timestamp]
          result = group.scores.send("#{interval}ly".to_sym).at(timestamp)
          if mode = permitted_params[:mode]
            result = result.send(mode.to_s.pluralize.to_sym)
          end
          paginated_response(result.readable_by(current_user))
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
          group = Group::Base.guarded_retrieve(current_user, permitted_params)
          paginated_response(group.managers.readable_by(current_user))
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
          group = Group::Base.guarded_retrieve(current_user, permitted_params)
          user  = User.unguarded_retrieve(data_id)
          group.managers.add(current_user, user)
          status 204
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
          group = Group::Base.guarded_retrieve(current_user, permitted_params)
          group.managers.replace(current_user, data_id_array, update: :replace_managers)
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
          group = Group::Base.guarded_retrieve(current_user, permitted_params)
          user  = User.unguarded_retrieve(data_id)
          group.managers.remove(current_user, user)
          status 204
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
          group = Group::Base.guarded_retrieve(current_user, permitted_params)
          paginated_response(group.members.readable_by(current_user))
        end


        desc "Return the related energy-producers for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
        oauth2 false
        get ":id/energy-producers" do
          group = Group::Base.guarded_retrieve(current_user, permitted_params)
          group.energy_producers.readable_by(current_user)
        end


        desc "Return the related energy-consumers for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
        oauth2 :simple, :full
        get ":id/energy-consumers" do
          group = Group::Base.guarded_retrieve(current_user, permitted_params)
          group.energy_consumers.readable_by(current_user)
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
          group = Group::Base.guarded_retrieve(current_user, permitted_params)
          paginated_response(group.comment_threads.readable_by(current_user))
        end


      end
    end
  end
end
