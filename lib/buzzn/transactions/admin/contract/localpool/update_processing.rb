require_relative '../localpool'
require_relative '../../../../schemas/transactions/admin/contract/localpool_processing/update'

class Transactions::Admin::Contract::Localpool::UpdateProcessing < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  around :db_transaction
  tee :update_nested
  map :update_localpool_processing_contract, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::Contract::Localpool::Processing::Update
  end

  # TODO move this to operation when done
  def update_nested(params:, resource:, **)
    changed = false
    if params[:tax_number]
      resource.tax_data.tax_number = params[:tax_number]
      params.delete(:tax_number)
      changed = true
    end
    if changed
      resource.tax_data.save!
    end
  end

end
