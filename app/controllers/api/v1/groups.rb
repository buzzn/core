module API
  module V1
    class Groups < Grape::API
      include API::V1::Defaults
      resource :groups do

        params do
          requires :id, type: String
          optional :timestamp, type: Time
          requires :duration, type: String, values: %w(year month day hour)
        end
        get ":id/charts" do
          group = Group::Base.guarded_retrieve(current_user, permitted_params)
          interval = Buzzn::Interval.create(params[:duration], params[:timestamp])
          result = Buzzn::Application.config.charts.for_group(group, interval)

          # cache-control headers
          etag(Digest::SHA256.base64digest(result.to_json))
          expires((result.expires_at - Time.current.to_f).to_i,
                  current_user ? :private : :public)
          last_modified(Time.at(result.last_timestamp))

          result
        end

        params do
          requires :id, type: String
        end
        get ":id/bubbles" do
          group = Group::BaseResource.retrieve(current_user, permitted_params)
          result = Buzzn::Application.config.current_power.for_each_register_in_group(group)

          # cache-control headers
          etag(Digest::SHA256.base64digest(result.to_json))
          last_modified(Time.at(result.expires_at))
          expires((result.expires_at - Time.current.to_f).to_i,
                  current_user ? :private : :public)

          result
        end

        resource :localpools do

          desc "Return the related localpool processing contract for the Localpool"
          params do
            requires :id, type: String, desc: "ID of the group"
          end
          get ":id/localpool-processing-contract" do
            Group::LocalpoolResource
              .retrieve(current_user, permitted_params)
              .localpool_processing_contract!
          end


          desc "Return the related metering_point operator contract for the Localpool"
          params do
            requires :id, type: String, desc: "ID of the group"
          end
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
        get ":id" do
          Group::BaseResource.retrieve(current_user, permitted_params)
        end




        desc "Return the related registers for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
        get ":id/registers" do
          Group::BaseResource
            .retrieve(current_user, permitted_params)
            .registers
        end


        desc "Return the related meters for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
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
        get ":id/scores" do
          Group::BaseResource
            .retrieve(current_user, permitted_params)
            .scores(permitted_params)
        end



        desc "Return the related managers for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
        get ':id/managers' do
          Group::BaseResource
            .retrieve(current_user, permitted_params)
            .managers
        end

        desc "Return the related members for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
        get ':id/members' do
          Group::BaseResource
            .retrieve(current_user, permitted_params)
            .members
        end


        desc "Return the related energy-consumers for Group"
        params do
          requires :id, type: String, desc: "ID of the group"
        end
        get ":id/energy-consumers" do
          Group::BaseResource
            .retrieve(current_user, permitted_params)
            .energy_consumers
        end

      end
    end
  end
end
