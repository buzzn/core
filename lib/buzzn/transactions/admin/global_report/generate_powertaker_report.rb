require_relative '../global_report'

class Transactions::Admin::GlobalReport::GeneratePowertakerReport < Transactions::Base

  add :generate_powertaker_report_file
  map :wrap_up

  include Import[
    powertaker_report_service: 'services.powertaker_report_service',
  ]

  def generate_powertaker_report_file
    powertaker_report_service.generate_powertaker_report_async
  end

  def wrap_up(generate_powertaker_report_file:, **)
    generate_powertaker_report_file
  end

end