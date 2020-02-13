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

  add :register_metas

  add :register_metas_active

  add :production_pv_consumend_in_group_kWh
  add :production_chp_consumend_in_group_kWh
  add :production_wind_consumend_in_group_kWh
  add :production_water_consumend_in_group_kWh

  add :production
  add :consumption
  add :renewable_eeg
  add :renewable_through_eeg
  add :non_eeg
  add :production_consumend_in_group_kWh
  add :autacry_in_percent
  add :additional_supply_ratio

  add :co2_emmision_g_per_kwh_coal
  add :co2_emmision_g_per_kwh_gas
  add :co2_emmision_g_per_kwh_other
  add :energy_mix
  map :build_result

  def schema
    Schemas::Transactions::Admin::Report::CreateElectricityLabelling
  end

  def build_result(warnings:,
                   energy_mix:,
                   autacry_in_percent:,
                   additional_supply_ratio:,
                   production_chp_consumend_in_group_kWh:,     # E18
                   production_pv_consumend_in_group_kWh:,      # E19
                   production_water_consumend_in_group_kWh:,   # E20
                   production_consumend_in_group_kWh:,         # E21
                   consumption:,                               # E15
                   production:,                                # E25
                   renewable_eeg:,
                   renewable_through_eeg:,
                   non_eeg:,
                   co2_emmision_g_per_kwh_coal:,
                   co2_emmision_g_per_kwh_gas:,
                   co2_emmision_g_per_kwh_other:,
                   **)
    current_energy_mix = energy_mix[:germany]
    fossils = current_energy_mix[:nuclear] +
              current_energy_mix[:coal] +
              current_energy_mix[:natural_gas] +
              current_energy_mix[:other_fossil] +
              current_energy_mix[:other_renewable] / BigDecimal('100') * autacry_in_percent * additional_supply_ratio

    coal_ratio = current_energy_mix[:coal] / fossils
    gas_ratio = current_energy_mix[:natural_gas] / fossils
    other_fossil = current_energy_mix[:other_fossil] / fossils
    nuclear_ratio = current_energy_mix[:nuclear] / fossils

    own_power_fraction = production_consumend_in_group_kWh * autacry_in_percent / non_eeg / BigDecimal('100')
    {
      warnings: warnings,

      # E68 ... Other power
      nuclear_ratio: nuclear_ratio,                                     # E69
      coal_ratio: coal_ratio,                                           # E70
      gas_ratio: gas_ratio,                                             # E71
      other_fossil: other_fossil,                                       # E72
      other_renewable: current_energy_mix[:other_renewable] / fossils,  # E73

      # E74 ... Own power
      natural_gas_bh: production_chp_consumend_in_group_kWh / own_power_fraction,          # E75
      other_renewable_pv: production_pv_consumend_in_group_kWh / own_power_fraction,       # E76
      other_renewable_water: production_water_consumend_in_group_kWh / own_power_fraction, # E77
      renewable_eeg_ratio: renewable_eeg / consumption * BigDecimal('100'),                # E78

      co2_emissions_g_per_kwh: (coal_ratio / BigDecimal('100') * co2_emmision_g_per_kwh_coal # E93
                                + gas_ratio / BigDecimal('100') * co2_emmision_g_per_kwh_gas
                                + other_fossil / BigDecimal('100') * co2_emmision_g_per_kwh_other),
      nuclearwaste_miligramm_per_kwh: nuclear_ratio / current_energy_mix[:nuclear] * BigDecimal('0.0001'), # E79
      renter_power_eeg: 0,
      self_sufficiency_report: (production_consumend_in_group_kWh / consumption * BigDecimal('100')), # E103
      utilization_report: consumption / production * BigDecimal('100'),           # E104
      gas_report: 1,                                                              # E83
      sun_report: 1,                                                              # E84
      electricitySupplier: 1,                                                     # E85
      tech: 1,                                                                    # E86
      natural_gas: current_energy_mix[:natural_gas] / fossils
    }
  end

  def register_metas_active(register_metas:, **)
    # A register is considered active if it has at least
    # one register not decomissioned/
    register_metas.select { |m| m.registers.any? { |r| !r.decomissioned? } }
  end

  # E18
  def production_chp_consumend_in_group_kWh(register_metas_active:, date_range:, warnings:, **)
    if register_metas_active.map(&:label).any? {|x| x == :demarcation_chp}
      return system(register_metas: register_metas_active, date_range: date_range, label: :grid_consumption, warnings: warnings) -
             system(register_metas: register_metas_active, date_range: date_range, label: :production_chp, warnings: warnings) -
             system(register_metas: register_metas_active, date_range: date_range, label: :demarcation_chp, warnings: warnings)
    end

    system(register_metas: register_metas_active, date_range: date_range, label: :grid_consumption, warnings: warnings) -
      system(register_metas: register_metas_active, date_range: date_range, label: :production_chp, warnings: warnings)
  end

  # E19
  def production_pv_consumend_in_group_kWh(register_metas_active:, date_range:, warnings:, **)
    if register_metas_active.map(&:label).any? {|x| x == :demarcation_pv}
      return system(register_metas: register_metas_active, date_range: date_range, label: :grid_consumption, warnings: warnings) -
             system(register_metas: register_metas_active, date_range: date_range, label: :production_pv, warnings: warnings) -
             system(register_metas: register_metas_active, date_range: date_range, label: :demarcation_pv, warnings: warnings)
    end

    system(register_metas: register_metas_active, date_range: date_range, label: :grid_consumption, warnings: warnings) -
      system(register_metas: register_metas_active, date_range: date_range, label: :production_pv, warnings: warnings)
  end

  # E20
  def production_water_consumend_in_group_kWh(register_metas_active:, date_range:, warnings:, **)
    if register_metas_active.map(&:label).any? {|x| x == :demarcation_water}
      return system(register_metas: register_metas_active, date_range: date_range, label: :grid_consumption, warnings: warnings) -
             system(register_metas: register_metas_active, date_range: date_range, label: :production_water, warnings: warnings) -
             system(register_metas: register_metas_active, date_range: date_range, label: :demarcation_water, warnings: warnings)
    end

    system(register_metas: register_metas_active, date_range: date_range, label: :grid_consumption, warnings: warnings) -
      system(register_metas: register_metas_active, date_range: date_range, label: :production_water, warnings: warnings)
  end

  def production_wind_consumend_in_group_kWh(register_metas_active:, date_range:, warnings:, **)
    if register_metas_active.map(&:label).any? {|x| x == :demarcation_wind}
      return system(register_metas: register_metas_active, date_range: date_range, label: :grid_consumption, warnings: warnings) -
             system(register_metas: register_metas_active, date_range: date_range, label: :production_wind, warnings: warnings) -
             system(register_metas: register_metas_active, date_range: date_range, label: :demarcation_wind, warnings: warnings)
    end

    system(register_metas: register_metas_active, date_range: date_range, label: :grid_consumption, warnings: warnings) -
      system(register_metas: register_metas_active, date_range: date_range, label: :production_wind, warnings: warnings)
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

  # E65
  def autacry_in_percent(consumption:, production_consumend_in_group_kWh:, **)
    (production_consumend_in_group_kWh / consumption) * 100
  end

  # E66
  def additional_supply_ratio(autacry_in_percent:, **)
    BigDecimal('100') - autacry_in_percent
  end

  # E34
  def renewable_eeg(**)
    BigDecimal('73032')
  end

  # E78
  def renewable_through_eeg(renewable_eeg:, consumption:, **)
    renewable_eeg / consumption * BigDecimal('100')
  end

  # E67
  def non_eeg(renewable_through_eeg:, **)
    BigDecimal('100') - renewable_through_eeg
  end

  # @param consumption_own_production_wh [number] Amount of electricity
  # consumed which has been produced within the group.
  # @param grid_consumption [number]
  def lsn_producted_consumption(consumption_own_production_wh:, grid_consumption:, **)
    consumption_own_production_wh + grid_consumption
  end

  # E28
  def full_levy_ct_per_kWh(**)
    BigDecimal('6.7920')
  end

  # E29
  def reduced_levy_ct_per_kWh(**)
    BigDecimal('2.7168')
  end

  # E30
  def consumption_eeg_full(**)
    BigDecimal('1.9') # todo
  end

  # E32
  # @return [BigDecimal] The levy paid by the local power giver.
  def paid_levy_by_local_power_giver(full_levy_ct_per_kWh:, veeg:,
                                     reduced_levy_ct_per_kWh:, veeg_reduced:, **)
    (full_levy * veeg + reduced_levy * veeg_reduced) / BigDecimal('100') # %
  end

  # E33
  def eeg_quotient(**)
    BigDecimal('8.188')
  end

  def co2_emmision_g_per_kwh_coal(**)
    BigDecimal('850')
  end

  def co2_emmision_g_per_kwh_gas(**)
    BigDecimal('640')
  end

  def co2_emmision_g_per_kwh_other(**)
    BigDecimal('859')
  end

  def energy_mix(**)
    {
      germany: {
        nuclear: BigDecimal('12.7'),
        coal: BigDecimal('38.1'),
        natural_gas: BigDecimal('10.2'),
        other_fossil: BigDecimal('2.4'),
        other_renewable: BigDecimal('3.5'),
        renewable_eeg: BigDecimal('33.1'),
        co2_emissions_g_per_kwh: BigDecimal('244'),
        radioactive_waste_g_per_kwh: BigDecimal('0.0001')
      },
      buzzn: {
        nuclear: BigDecimal('4.1'),
        coal: BigDecimal('11.9'),
        natural_gas: BigDecimal('27.7'),
        other_fossil: BigDecimal('0.6'),
        other_renewable: BigDecimal('0.1'),
        renewable_eeg: BigDecimal('55.6'),
        co2_emissions_g_per_kwh: BigDecimal('244'),
        radioactive_waste_g_per_kwh: BigDecimal('0.0001')
      }
      # others to come
    }
  end

end
