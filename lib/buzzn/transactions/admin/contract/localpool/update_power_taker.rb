require_relative '../localpool'
require_relative '../../../../schemas/transactions/admin/contract/localpool_power_taker/update'

class Transactions::Admin::Contract::Localpool::UpdatePowerTaker < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  around :db_transaction
  tee :update_nested, with: :'operations.action.stale'
  map :update_localpool_power_taker_contract, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::Contract::Localpool::PowerTaker::Update
  end

  def update_nested(params:, resource:, **)
    if params[:register_meta].nil?
      return
    end
    super(params: params[:register_meta], resource: resource.market_location)
    changed = false
    if params[:register_meta]
      resource.market_location.object.update(params[:register_meta])
      params.delete(:register_meta)
      changed = true
    end
    if changed
      resource.market_location.object.save!
    end
  end

end
