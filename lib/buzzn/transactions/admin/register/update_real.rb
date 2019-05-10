require_relative '../register'

class Transactions::Admin::Register::UpdateReal < Transactions::Base

  validate :schema
  tee :meta_schema
  check :authorize, with: :'operations.authorization.update'
  around :db_transaction
  tee :find_or_create_meta
  map :update, with: 'operations.action.update'

  def schema
    Schemas::Transactions::Admin::Register::UpdateReal
  end

  def meta_schema(params:, **)
    unless params[:meta].nil?
      schema = if params[:meta][:id].nil?
                 Schemas::Transactions::Admin::Register::CreateMeta
               else
                 Schemas::Transactions::Assign
               end
      result = schema.call(params[:meta])
      if result.success?
        Success(params[:meta] = result.output)
      else
        raise Buzzn::ValidationError.new(result.errors)
      end
    end
  end

  def find_or_create_meta(resource:, params:, **)
    metap = params[:meta]
    meta = if metap.nil?
             nil
           elsif metap[:id].nil?
             market_location_id = metap.delete(:market_location_id)
             unless market_location_id.nil?
               metap[:market_location] = Register::MarketLocation.find_by_market_location_id(market_location_id) ||
                                         Register::MarketLocation.create(market_location_id: market_location_id)
             end
             Register::Meta.create(metap)
           else
             begin
               Register::Meta.find(metap[:id])
             rescue ActiveRecord::RecordNotFound
               raise Buzzn::ValidationError.new(meta: [:id => 'object does not exist'])
             end
           end
    if resource.object.meta != meta
      if !resource.object.meta.nil? && resource.object.meta.contracts.empty? && resource.object.meta.registers.count == 1
        raise Buzzn::ValidationError.new(meta: [:id => 'old register_meta would orphan'])
      end
    end
    params[:meta] = meta
  end

end
