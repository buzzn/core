require_relative '../contract'

class Transactions::Admin::Contract::CreatePowerTakerBase < Transactions::Base

  tee :assign_contractor
  tee :assign_register_meta
  map :create_contract, with: :'operations.action.create_item'

  def assign_contractor(params:, localpool:, **)
    params[:contractor] = localpool.owner.object
  end

  def assign_register_meta(params:, **)
    params[:register_meta] = Register::Meta.create(name: params[:register_meta][:name], share_with_group: false, share_publicly: false, label: :consumption)
  end

  def create_contract(params:, resource:, **)
    Contract::LocalpoolPowerTakerResource.new(
      *super(resource, params)
    )
  end

end
