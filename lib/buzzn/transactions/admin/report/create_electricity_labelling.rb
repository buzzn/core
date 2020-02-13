
require_relative '../report'
require_relative './report_data.rb'
require_relative '../../../schemas/transactions/admin/report/create_electricity_labelling'
require_relative '../../../transactions'

require 'bigdecimal'
require 'time'

# Creates an annual report as an excel sheet of a given group.
class Transactions::Admin::Report::CreateElectricityLabelling < Transactions::Admin::Report::ReportData

  #validate :schema
  authorize :allowed_roles
  tee :end_date, with: :'operations.end_date'
  add :warnings
  add :date_range
  #add :register_metas
  add :production
  add :grid_feeding
  add :grid_consumption
  add :contracts_with_range
  add :contracts_with_range_and_readings
  add :grid_consumption_corrected
  add :grid_feeding_corrected
  add :veeg
  add :veeg_reduced
  add :consumption
  add :energy_mix
  add :register_metas_active
  add :production_pv_consumend_in_group_kWh
  add :production_chp_consumend_in_group_kWh 
  add :production_wind_consumend_in_group_kWh
  add :production_water_consumend_in_group_kWh
  add :production_consumend_in_group_kWh
  add :autacry_in_percent
  add :additional_supply_ratio
  map :build_result

  def warnings(**)
    []
  end

  def schema
    Schemas::Transactions::Admin::Report::CreateElectricityLabelling
  end

  def build_result(resource:,
                   contracts_with_range_and_readings:,
                   production:,
                   grid_feeding:,
                   grid_consumption:,
                   grid_consumption_corrected:,
                   grid_feeding_corrected:,
                   veeg:,
                   veeg_reduced:,
                   warnings:,
                   energy_mix:,
                   autacry_in_percent:,
                   additional_supply_ratio:,
                   **)
    energy_mix = energy_mix[:germany]

    fossils = energy_mix[:nuclear] +
              energy_mix[:coal] +
              energy_mix[:natural_gas] +
              energy_mix[:other_fossil] +
              energy_mix[:other_renewable] / 100 * autacry_in_percent * additional_supply_ratio
    {
      warnings: warnings,
      nuclear: energy_mix[:nuclear] / fossils,
      coal: energy_mix[:coal] / fossils,
      natural_gas: energy_mix[:natural_gas] / fossils,
      other_fossil: energy_mix[:other_fossil] / fossils,
      other_renewable: energy_mix[:other_renewable] / fossils
    }.merge(contracts_with_range_and_readings)
  end

  def register_metas_active(register_metas:, **)
    # A register is considered active if it has at least
    # one register not decomissioned
    register_metas.select { |m| m.registers.any? { |r| !r.decomissioned? } }
  end

  def production_pv_consumend_in_group_kWh(register_metas_active:, date_range:, warnings:, **)
    if register_metas.map(&:label).any?(:demarcation_pv)
      return system(register_metas_active, date_range, :grid_consumption, warnings) -
             system(register_metas_active, date_range, :production_pv, warnings) -
             system(register_metas_active, date_range, :demarcation_pv, warnings)
    end

    system(register_metas_active, date_range, :grid_consumption, warnings) -
      system(register_metas_active, date_range, :production_pv, warnings)
  end

  def production_chp_consumend_in_group_kWh(register_metas_active:, date_range:, warnings:, **)
    if register_metas.map(&:label).any?(:demarcation_chp)
      return system(register_metas_active, date_range, :grid_consumption, warnings) -
             system(register_metas_active, date_range, :production_chp, warnings) -
             system(register_metas_active, date_range, :demarcation_chp, warnings)
    end

    system(register_metas_active, date_range, :grid_consumption, warnings) -
      system(register_metas_active, date_range, :production_chp, warnings)
  end

  def production_water_consumend_in_group_kWh(register_metas_active:, date_range:, warnings:, **)
    if register_metas.map(&:label).any?(:demarcation_water)
      return system(register_metas_active, date_range, :grid_consumption, warnings) -
             system(register_metas_active, date_range, :production_water, warnings) -
             system(register_metas_active, date_range, :demarcation_water, warnings)
    end

    system(register_metas_active, date_range, :grid_consumption, warnings) -
      system(register_metas_active, date_range, :production_water, warnings)
  end

  def production_wind_consumend_in_group_kWh(register_metas_active:, date_range:, warnings:, **)
    if register_metas.map(&:label).any?(:demarcation_wind)
      return system(register_metas_active, date_range, :grid_consumption, warnings) -
             system(register_metas_active, date_range, :production_wind, warnings) -
             system(register_metas_active, date_range, :demarcation_wind, warnings)
    end

    system(register_metas_active, date_range, :grid_consumption, warnings) -
      system(register_metas_active, date_range, :production_wind, warnings)
  end

  def production_consumend_in_group_kWh(
    production_pv_consumend_in_group_kWh:,
    production_chp_consumend_in_group_kWh:,
    production_wind_consumend_in_group_kWh:,
    production_water_consumend_in_group_kWh:,
    **
  )
    production_pv_consumend_in_group_kWh +
      production_chp_consumend_in_group_kWh +
      production_wind_consumend_in_group_kWh +
      production_water_consumend_in_group_kWh
  end

  def autacry_in_percent(consumption:, production_consumend_in_group_kWh:, **)
    (production_consumend_in_group_kWh / consumption) * 100
  end

  def additional_supply_ratio(autacry_in_percent:, **)
    BigDecimal('100') - autacry_in_percent
  end

  #  demarcation_pv demarcation_chp demarcation_wind demarcation_water
  # production_pv production_chp production_wind production_water

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
