# coding: utf-8

require_relative '../global_report'

class Transactions::Admin::GlobalReport::GenerateMeterReport < Transactions::Base

  add :generate_report_file
  map :wrap_up

  include Import[
    meter_report_service: 'services.meter_report_service',
  ]

  def generate_report_file
    meter_report_service.generate_meter_report_async
  end

  def wrap_up(generate_report_file:, **)
    generate_report_file
  end

end