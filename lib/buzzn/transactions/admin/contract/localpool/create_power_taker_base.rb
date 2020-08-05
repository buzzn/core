require_relative '../localpool'

class Transactions::Admin::Contract::Localpool::CreatePowerTakerBase < Transactions::Base

  def localpool_schema(localpool:, **)
    subject = Schemas::Support::ActiveRecordValidator.new(localpool.object)
    result = Schemas::PreConditions::Localpool::CreateLocalpoolPowerTakerContract.call(subject)
    unless result.success?
      raise Buzzn::ValidationError.new(result.errors, localpool.object)
    end
  end

  def register_meta_schema(params:, **)
    validation_errors = {}
    if params[:register_meta][:id].nil?
      schema = Schemas::Transactions::Admin::Register::CreateMeta
    else
      schema = Schemas::Transactions::Assign
    end
    result = schema.call(params[:register_meta])
    if result.success?
      Success(params[:register_meta].replace(result.output))
    else
      validation_errors[:register_meta] = result.errors
    end

    unless validation_errors[:register_meta].nil?
      raise Buzzn::ValidationError.new(validation_errors)
    end
  end

  def assign_contractor(params:, localpool:, **)
    params[:contractor] = localpool.owner.object
    params[:contractor_bank_account] = localpool.owner.object.bank_accounts.count.positive? ? localpool.owner.object.bank_accounts.first : nil
  end

  def assign_register_meta(params:, **)
    begin
      register_meta = params[:register_meta][:id].nil? ? params[:register_meta] = Register::Meta.create(params[:register_meta])
                                                       : Register::Meta.find(params[:register_meta][:id])
      begin_date = params[:begin_date]
      register_meta.contracts.each do |contract|
        if contract.status(begin_date) == Contract::Base::ACTIVE
          raise Buzzn::ValidationError.new({register_meta: ["other contract with id #{contract.id} active at begin"]}, contract)
        end
      end
      params[:register_meta] = register_meta
    rescue ActiveRecord::RecordNotFound
      raise Buzzn::ValidationError.new({register_meta: [ :id => 'object does not exist']}, contract)
    end
  end

  def create_register_meta_options(params:, **)
    params_register_meta = {}
    unless params[:share_register_publicly].nil?
      params_register_meta[:share_publicly] = params.delete(:share_register_publicly)
    end
    unless params[:share_register_with_group].nil?
      params_register_meta[:share_with_group] = params.delete(:share_register_with_group)
    end

    params[:register_meta_option] = Register::MetaOption.create(params_register_meta)
  end

  def create_tax_data(params:, **)
    params[:tax_data] = Contract::TaxData.new(creditor_identification: params.delete(:creditor_identification))
  end

  def create_contract(params:, resource:, **)
    Contract::LocalpoolPowerTakerResource.new(
      *super(resource, params)
    )
  end

end
