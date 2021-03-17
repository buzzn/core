# coding: utf-8

require_relative '../billing_cycle'
require 'rubyXL'

class Transactions::Admin::BillingCycle::ReturnReport < Transactions::Base

  add :return_report_file
  tee :delete_report
  map :wrap_up

  def return_report_file(params:)
    local_file_path = File.join(File.dirname(File.expand_path(__FILE__)), "../../../../../db/reports/#{params['id']}.xlsx")
    if File.exist?(local_file_path)
        workbook = RubyXL::Parser.parse(local_file_path)
        workbook.stream
    else
        raise Buzzn::ValidationError.new("The report has not yet been completely generated.")
    end
  end

  def delete_report(return_report_file:, params:)
    local_file_path = File.join(File.dirname(File.expand_path(__FILE__)), "../../../../../db/reports/#{params['id']}.xlsx")
    if File.exist?(local_file_path)
        File.delete(local_file_path)
    else
        raise Buzzn::ValidationError.new("The report could not be deleted")
    end
  end

  def wrap_up(return_report_file:, **)
    return_report_file
  end

end