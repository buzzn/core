module API
  module V1
    class Groups < Grape::API
      include API::V1::Defaults
      resource :groups do



        resource :localpools do
          desc "Return all Localpools"
          params do
            optional :filter, type: String, desc: "Search query using #{Base.join(Group::Base.search_attributes)}"
            optional :order_direction, type: String, default: 'DESC', values: ['DESC', 'ASC'], desc: "Ascending Order and Descending Order"
            optional :order_by, type: String, default: 'created_at', values: ['name', 'updated_at', 'created_at'], desc: "Order by Attribute"
          end
          oauth2 false
          get do
            order = "#{permitted_params[:order_by]} #{permitted_params[:order_direction]}"
            Group::LocalpoolResource
              .all(current_user, permitted_params[:filter])
              .order(order)
          end


          desc "Return the related localpool processing contract for the Localpool"
          params do
            requires :id, type: String, desc: "ID of the group"
          end
          oauth2 :full
          get ":id/localpool-processing-contract" do
            Group::LocalpoolResource
              .retrieve(current_user, permitted_params)
              .localpool_processing_contract!
          end


          desc "Return the related metering_point operator contract for the Localpool"
          params do
            requires :id, type: String, desc: "ID of the group"
          end
          oauth2 :full
          get ":id/metering-point-operator-contract" do
            Group::LocalpoolResource
              .retrieve(current_user, permitted_params)
              .metering_point_operator_contract!
          end

        end







        desc "Return all groups"
        params do
          optional :filter, type: String, desc: "Search query using #{Base.join(Group::Base.search_attributes)}"
          optional :order_direction, type: String, default: 'DESC', values: ['DESC', 'ASC'], desc: "Ascending Order and Descending Order"
          optional :order_by, type: String, default: 'created_at', values: ['name', 'updated_at', 'created_at'], desc: "Order by Attribute"
        end
        oauth2 false
        get do
          order = "#{permitted_params[:order_by]} #{permitted_params[:order_direction]}"
          Group::BaseResource
            .all(current_user, permitted_params[:filter])
            .order(order)
        end



        desc "Return a Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
        oauth2 false
        get ":id" do
          Group::BaseResource.retrieve(current_user, permitted_params)
        end



        desc "Update a Group"
        params do
          requires :id, type: String, desc: "Group ID."
          optional :name
        end
        oauth2 :full
        patch ':id' do
          Group::BaseResource
            .retrieve(current_user, permitted_params)
            .update(permitted_params)
        end



        desc 'Delete a Group'
        params do
          requires :id, type: String, desc: "Group ID"
        end
        oauth2 :full
        delete ':id' do
          deleted_response(Group::BaseResource
                            .retrieve(current_user, permitted_params)
                            .delete)
        end



        desc "Return the related registers for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
        oauth2 false
        get ":id/registers" do
          Group::BaseResource
            .retrieve(current_user, permitted_params)
            .registers
        end


        desc "Return the related meters for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
        oauth2 :full
        get ":id/meters" do
          Group::BaseResource
            .retrieve(current_user, permitted_params)
            .meters
        end


        desc "Return the related scores for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
          requires :interval, type: Symbol, values: [:day, :month, :year]
          requires :timestamp, type: DateTime
          optional :mode, type: Symbol, values: [:sufficiency, :closeness, :autarchy, :fitting]
        end
        oauth2 false
        get ":id/scores" do
          Group::BaseResource
            .retrieve(current_user, permitted_params)
            .scores(permitted_params)
        end



        desc "Return the related managers for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
        oauth2 :simple, :full
        get [':id/managers', ':id/relationships/managers'] do
          Group::BaseResource
            .retrieve(current_user, permitted_params)
            .managers
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
          status 200
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
        end
        oauth2 :simple, :full
        get [':id/members', ':id/relationships/members'] do
          Group::BaseResource
            .retrieve(current_user, permitted_params)
            .members
        end


        desc "Return the related energy-producers for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
        oauth2 false
        get ":id/energy-producers" do
          Group::BaseResource
            .retrieve(current_user, permitted_params)
            .energy_producers
        end


        desc "Return the related energy-consumers for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
        oauth2 :simple, :full
        get ":id/energy-consumers" do
          Group::BaseResource
            .retrieve(current_user, permitted_params)
            .energy_consumers
        end


        desc 'Return the related comments for Group'
        params do
          requires :id, type: String, desc: 'ID of the group'
        end
        oauth2 :simple, :full
        get ':id/comments' do
          Group::BaseResource
            .retrieve(current_user, permitted_params)
            .comments
        end


      end
    end
  end
end
