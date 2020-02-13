require_relative 'report_data'
require_relative '../../../schemas/transactions/admin/report/create_eeg_report'

class Transactions::Admin::Report::CreateEegReport < Transactions::Admin::Report::ReportData

  validate :schema
  authorize :allowed_roles
  tee :end_date, with: :'operations.end_date'
  add :warnings
  add :date_range
  add :register_metas
  add :production
  add :grid_feeding
  add :grid_consumption
  add :contracts_with_range
  add :contracts_with_range_and_readings
  add :grid_consumption_corrected
  add :grid_feeding_corrected
  add :veeg
  add :veeg_reduced
  map :build_result

  def schema
    Schemas::Transactions::Admin::Report::CreateEegReport
  end

  def build_result(contracts_with_range_and_readings:,
                   production:,
                   grid_feeding:,
                   grid_consumption:,
                   grid_consumption_corrected:,
                   grid_feeding_corrected:,
                   veeg:,
                   veeg_reduced:,
                   warnings:,
                   **)
    {
      warnings: warnings,
      production_wh:       production,
      grid_feeding_wh:     grid_feeding,
      grid_consumption_wh: grid_consumption,
      grid_consumption_corrected_wh: grid_consumption_corrected,
      grid_feeding_corrected_wh: grid_feeding_corrected,
      veeg_wh: veeg,
      veeg_reduced_wh: veeg_reduced,
    }.merge(contracts_with_range_and_readings)
  end

end
