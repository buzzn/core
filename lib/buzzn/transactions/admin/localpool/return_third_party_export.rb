require_relative '../localpool'
require 'rubyXL'

class Transactions::Admin::Localpool::ReturnThirdPartyExport < Transactions::Base

  add :return_export_file
  tee :delete_export
  map :wrap_up
  
  def return_export_file(params:)
    ReportDocument.load_document(params['id'])
  end
  
  def delete_export(return_export_file:, params:)
    ReportDocument.delete_document(params['id'])
  end
  
  def wrap_up(return_export_file:, **)
    return_export_file
  end
  
end 
