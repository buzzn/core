require_relative '../localpool'
require_relative '../../../../schemas/transactions/admin/contract/localpool_metering_point_operator/update'

class Transactions::Admin::Contract::Localpool::UpdateMeteringPointOperator < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  around :db_transaction
  map :update_metering_point_operator_contract, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::Contract::Localpool::MeteringPointOperator::Update
  end

end
