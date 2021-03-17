# coding: utf-8

require_relative '../billing_cycle'

class Transactions::Admin::BillingCycle::GenerateReport < Transactions::Base

  add :generate_report_file
  map :wrap_up

  include Import[
    report_service: 'services.report_service',
  ]

  def generate_report_file(resource:, params:)
    report_service.generate_report_async(resource.object.id)
  end

  def wrap_up(generate_report_file:, **)
    generate_report_file
  end

end
