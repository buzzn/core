# coding: utf-8

require_relative '../global_report'
require 'rubyXL'

class Transactions::Admin::GlobalReport::ReturnReport < Transactions::Base

  add :return_report_file
  tee :delete_report
  map :wrap_up

  def return_report_file(params:)
    ReportDocument.load_document(params['id'])
  end

  def delete_report(return_report_file:, params:)
    ReportDocument.delete_document(params['id'])
  end

  def wrap_up(return_report_file:, **)
    return_report_file
  end

end