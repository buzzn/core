require_relative '../localpool'

class Transactions::Admin::Localpool::GenerateThirdPartyExport < Transactions::Base

  add :generate_export_file
  map :wrap_up

  include Import[
    report_service: 'services.report_service',
  ]

  def generate_export_file(resource:, params:)
    report_service.generate_export_async(resource.object.id)
  end

  def wrap_up(generate_export_file:, **)
    generate_export_file
  end

end