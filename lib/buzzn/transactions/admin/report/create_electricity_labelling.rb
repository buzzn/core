
require_relative '../report'
require_relative './report_data.rb'
require_relative '../../../schemas/transactions/admin/report/create_electricity_labelling'
require_relative '../../../transactions'

require 'bigdecimal'

# Creates an annual report as an excel sheet of a given group.
class Transactions::Admin::Report::CreateAnnualReport < Transactions::Admin::Report::ReportData

  validate :schema
  authorize :allowed_roles
  tee :end_date, with: :'operations.end_date'
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
    Schemas::Transactions::Admin::Report::CreateElectricityLabelling
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

  # @param consumption_own_production_wh [number] Amount of electricity
  # consumed which has been produced within the group.
  # @param grid_consumption [number] 
  def lsn_consumption(consumption_own_production_wh:, grid_consumption:)
    consumption_own_production_wh + grid_consumption
  end

  def full_levy_ct_per_kWh
    BigDecimal('6.88')
  end

  def reduced_levy_ct_per_kWh
    BigDecimal('2.7520')
  end

  # @return [BigDecimal] The levy paid by the local power giver.
  def paid_levy_by_local_power_giver(full_levy_ct_per_kWh:, veeg:,
                                     reduced_levy_ct_per_kWh:, veeg_reduced:)
    (full_levy * veeg + reduced_levy * veeg_reduced) / BigDecimal('100') # %
  end

  def eeg_quotient
    BigDecimal('7.99')
  end

  def renewable_eeg
    BigDecimal('73032')
  end

  def energy_mix
    {
      germany: {
        nuclear: 12.7,
        coal: 38.1,
        natural_gas: 10.2,
        other_fossil: 2.4,
        other_renewable: 3.5,
        renewable_eeg: 33.1,
        co2_emissions_g_per_kwh: 244,
        radioactive_waste_g_per_kwh: 0.0001
      },
      buzzn: {
        nuclear: 4.1,
        coal: 11.9,
        natural_gas: 27.7,
        other_fossil: 0.6,
        other_renewable: 0.1,
        renewable_eeg: 55.6,
        co2_emissions_g_per_kwh: 244,
        radioactive_waste_g_per_kwh: 0.0001
      }
      # others to come
    }
  end

end
