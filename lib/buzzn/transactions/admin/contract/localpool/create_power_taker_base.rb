require_relative '../localpool'

class Transactions::Admin::Contract::Localpool::CreatePowerTakerBase < Transactions::Base

  def localpool_schema(localpool:, **)
    subject = Schemas::Support::ActiveRecordValidator.new(localpool.object)
    result = Schemas::PreConditions::Localpool::CreateLocalpoolPowerTakerContract.call(subject)
    unless result.success?
      raise Buzzn::ValidationError.new(result.errors)
    end
  end

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
