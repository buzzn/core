require_relative '../localpool'
require_relative '../../../../schemas/transactions/admin/contract/localpool_power_taker/update'

class Transactions::Admin::Contract::Localpool::UpdatePowerTaker < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  around :db_transaction
  tee :update_register_meta, with: :'operations.action.update'
  tee :update_register_meta_options
  map :update_localpool_power_taker_contract, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::Contract::Localpool::PowerTaker::Update
  end

  def update_register_meta(params:, resource:, **)
    if params[:register_meta].nil?
      return
    end
    super(params: params.delete(:register_meta), resource: resource.market_location)
  end

  def update_register_meta_options(params:, resource:, **)
    params_register_meta_options = {}
    unless params[:share_register_publicly].nil?
      params_register_meta_options[:share_publicly] = params.delete(:share_register_publicly)
    end
    unless params[:share_register_with_group].nil?
      params_register_meta_options[:share_with_group] = params.delete(:share_register_with_group)
    end
    resource.object.register_meta_option.update(params_register_meta_options)
  end

end
