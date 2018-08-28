require_relative './create_power_taker_base'

module Transactions::Admin::Contract
  class CreatePowerTakerAssign < CreatePowerTakerBase

    validate :schema
    check :authorize, with: :'operations.authorization.create'
    around :db_transaction
    tee :assign_customer
    tee :assign_contractor
    tee :assign_register_meta
    map :create_contract, with: :'operations.action.create_item'

    def schema
      Schemas::Transactions::Admin::Contract::PowerTaker::CreateWithAssign
    end

    def assign_customer(params:, **)
      # this might also go into the schema
      begin
        params[:customer] = if params[:customer][:type] == 'organization'
                              Organization::General.find(params[:customer][:id])
                            else
                              Person.find(params[:customer][:id])
                            end
      rescue ActiveRecord::RecordNotFound
        raise Buzzn::ValidationError.new(customer: { :id => 'object does not exist'})
      end
    end

  end
end
