module API
  module V1
    class Aggregates < Grape::API
      include API::V1::Defaults
      resource :aggregates do






        desc "Aggregate Power"
        params do
          requires :register_ids, type: String, desc: "register IDs"
          optional :timestamp, type: DateTime
        end
        oauth2 false
        get 'present' do

          registers = Register::Base.where(id: permitted_params[:register_ids].split(","))
          registers_hash = Aggregate.sort_registers(registers)

          if registers.size > 5
            error!('maximum 5 registers per request', 413)
          else
            if registers_hash[:data_sources].size > 1
              error!('it is not possible to sum registers with differend data_source', 406)
            else
              registers.each do |register|
                register.guarded_read(current_user, :group_inheritance)
              end
              return Aggregate.new(registers_hash).present( { timestamp: permitted_params[:timestamp] })
            end
          end

        end







        desc "Aggregate Past"
        params do
          requires :register_ids, type: String, desc: "register IDs"
          optional :timestamp, type: DateTime
          optional :resolution, type: String, values: %w(
                                                        year_to_months
                                                        month_to_days
                                                        week_to_days
                                                        day_to_hours
                                                        day_to_minutes
                                                        hour_to_minutes
                                                        minute_to_seconds
                                                        )
        end
        oauth2 false
        get 'past' do

          registers = Register::Base.where(id: permitted_params[:register_ids].split(","))
          registers_hash = Aggregate.sort_registers(registers)

          if registers.size > 5
            error!('maximum 5 registers per request', 413)
          else
            if registers_hash[:data_sources].size > 1
              error!('it is not possible to sum registers with differend data_source', 406)
            else
              registers.each do |register|
                register.guarded_read(current_user, :group_inheritance)
              end
              return Aggregate.new(registers_hash).past( { timestamp: permitted_params[:timestamp], resolution: params[:resolution] })
            end
          end

        end






      end
    end
  end
end
