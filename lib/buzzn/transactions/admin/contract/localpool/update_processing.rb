require_relative '../localpool'
require_relative '../../../../schemas/transactions/admin/contract/localpool_processing/update'

class Transactions::Admin::Contract::Localpool::UpdateProcessing < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  tee :set_end_date, with: :'operations.end_date'
  around :db_transaction
  tee :update_nested
  map :update_localpool_processing_contract, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::Contract::Localpool::Processing::Update
  end

  # TODO move this to operation when done
  def update_nested(params:, resource:, **)
    tax_data = if resource.tax_data.nil?
                 Contract::TaxData.new
               else
                 resource.object.tax_data
               end
    if params[:tax_number]
      tax_data.tax_number = params.delete(:tax_number)
    elsif params[:sales_tax_number]
      tax_data.sales_tax_number = params.delete(:sales_tax_number)
    end
    tax_data.save
    params[:tax_data] = tax_data
  end

end
