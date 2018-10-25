require_relative '../register'
require_relative '../../../schemas/transactions/admin/register/update_meta'

class Transactions::Admin::Register::UpdateMeta < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  around :db_transaction
  tee :assign_market_location_id
  map :update, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::Register::UpdateMeta
  end

  def assign_market_location_id(params:, **)
    market_location_id = params.delete(:market_location_id)
    if market_location_id.nil?
      params[:market_location_id] = nil
    else
      params[:market_location] = Register::MarketLocation.find_by_market_location_id(market_location_id) ||
                                 Register::MarketLocation.create(market_location_id: market_location_id)
    end
  end

end
