# coding: utf-8
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

  add :contracts_with_range
  add :register_metas_active
  add :contracts_with_range_and_readings
  add :grid_feeding
  add :grid_consumption
  add :grid_feeding_corrected

  add :production_pv
  add :production_chp
  add :production_wind
  add :production_water

  add :production_pv_consumend_in_group_kWh
  add :production_chp_consumend_in_group_kWh
  add :production_wind_consumend_in_group_kWh
  add :production_water_consumend_in_group_kWh

  add :production
  add :grid_consumption_corrected
  add :veeg
  add :veeg_reduced
  add :full_levy_ct_per_kWh
  add :reduced_levy_ct_per_kWh
  add :consumption_eeg_full
  add :consumption_eeg_reduced
  add :consumption_without_third_party
  add :paid_levy_by_local_power_giver
  add :eeg_quotient
  add :renewable_eeg
  add :renewable_through_eeg

  add :renter_power
  add :non_eeg
  add :production_consumend_in_group_kWh
  add :autacry_in_percent
  add :additional_supply_ratio


  add :co2_emmision_g_per_kwh_coal
  add :co2_emmision_g_per_kwh_gas
  add :co2_emmision_g_per_kwh_other

  add :technologies
  add :utilization_report
  add :self_sufficiency_report

  add :electricity_supplier

  add :energy_mix
  map :build_result

  def schema
    Schemas::Transactions::Admin::Report::CreateElectricityLabelling
  end

  def build_result(warnings:,
                   resource:,
                   energy_mix:,
                   autacry_in_percent:,
                   additional_supply_ratio:,
                   production_chp_consumend_in_group_kWh:,     # E18
                   production_pv_consumend_in_group_kWh:,      # E19
                   production_water_consumend_in_group_kWh:,   # E20
                   production_consumend_in_group_kWh:,         # E21
                   consumption_without_third_party:,           # E15
                   production:,                                # E25
                   renewable_eeg:,
                   renewable_through_eeg:,
                   non_eeg:,                                   # E67
                   renter_power:,
                   technologies:,
                   co2_emmision_g_per_kwh_coal:,
                   co2_emmision_g_per_kwh_gas:,
                   co2_emmision_g_per_kwh_other:,
                   production_pv:,
                   production_chp:,
                   production_wind:,
                   production_water:,
                   utilization_report:,
                   self_sufficiency_report:,
                   electricity_supplier:,
                   consumption_eeg_reduced:,
                   consumption_eeg_full:,
                   **)
    current_energy_mix = energy_mix[:buzzn]
    fossils = BigDecimal('1') / (current_energy_mix[:nuclear] +
              current_energy_mix[:coal] +
              current_energy_mix[:natural_gas] +
              current_energy_mix[:other_fossil] +
              current_energy_mix[:other_renewable]) * BigDecimal('100') * additional_supply_ratio / BigDecimal('100') * non_eeg / BigDecimal('100')

    own_power_fraction = BigDecimal('1') / production_consumend_in_group_kWh * 100 * autacry_in_percent / 100 * non_eeg / 100

    coal_ratio = current_energy_mix[:coal] * fossils
    gas_ratio = current_energy_mix[:natural_gas] * fossils + production_chp_consumend_in_group_kWh * own_power_fraction
    other_fossil = current_energy_mix[:other_fossil] * fossils
    nuclear_ratio = current_energy_mix[:nuclear] * fossils
    other_renewable = current_energy_mix[:other_renewable] * fossils
    other_renewable_pv = production_pv_consumend_in_group_kWh * own_power_fraction       # E76
    other_renewable_water = production_water_consumend_in_group_kWh * own_power_fraction # E77

    co2_emission_gramm_per_kwh = (coal_ratio / BigDecimal('100') * co2_emmision_g_per_kwh_coal +
      gas_ratio / BigDecimal('100') * co2_emmision_g_per_kwh_gas +
      other_fossil / BigDecimal('100') * co2_emmision_g_per_kwh_other).round(1) # E93


    stats = {
      # E68 ... Other power
      nuclearRatio: nuclear_ratio.round(1),                                         # E69
      coalRatio: coal_ratio.round(1),                                               # E70
      gasRatio: gas_ratio.round(1),                                                 # E71
      otherFossilesRatio: other_fossil.round(1),                                    # E72
      otherRenewablesRatio: (other_renewable + other_renewable_pv + other_renewable_water).round(1), # E73
      renewablesEegRatio: renewable_through_eeg.round(1), # E78
      co2EmissionGrammPerKwh: co2_emission_gramm_per_kwh,
      nuclearWasteMiligrammPerKwh: (nuclear_ratio / current_energy_mix[:nuclear] * BigDecimal('0.0001')).round(4), # E79
      renterPowerEeg: renter_power.round(1),
      selfSufficiencyReport: self_sufficiency_report.round(1),                                                                            # E103
      utilizationReport: utilization_report.round(1),                                                                                     # E104
      electricitySupplier: electricity_supplier, # E85
      tech: technologies, # E86
    }

    if production.positive?
      stats.merge!(
        gasReport: (BigDecimal('100') * production_chp / production).to_i, # E83
        sunReport: (BigDecimal('100') * production_pv / production).to_i,  # E84
        waterReport: (BigDecimal('100') * production_water / production).to_i, # E84
        windReport: (BigDecimal('100') * production_wind / production).to_i # E84
      )

      # Make sure that the sum of all reports is 100 %, add the round error to the largest value
      techs = [:gasReport, :sunReport, :waterReport, :windReport]
      sum_techs = techs.map {|x| stats[x]}.sum

      largest = :gasReport
      largest_value = stats[largest]
      techs.each do |t|
        if stats[t] > largest_value
          largest = t
          largest_value = stats[t]
        end
      end

      stats[largest] = 100 - sum_techs + largest_value
    else
      stats.merge!(
        gasReport: 0,
        sunReport: 0,
        waterReport: 0,
        windReport: 0
      )
    end

    # The rounding meant, the ratios will not be 100% anymore, so we cheat here, don't tell anyone.
    checksum = (stats[:nuclearRatio] + stats[:coalRatio] + stats[:gasRatio] +
      stats[:otherFossilesRatio] + stats[:otherRenewablesRatio] + stats[:renewablesEegRatio] + stats[:renterPowerEeg])

    stats[:coalRatio] -= checksum - 100

    resource.object.fake_stats = stats
    resource.save
    stats.merge!(
      warnings: warnings,
      chp: production_chp_consumend_in_group_kWh,
      pv: production_pv_consumend_in_group_kWh,
      water: production_water_consumend_in_group_kWh,
      # E74 ... Own power
      natural_gas_bh: production_chp_consumend_in_group_kWh * own_power_fraction, # E75
      other_renewable_pv: other_renewable_pv,       # E76
      other_renewable_water: other_renewable_water, # E77
      own_power_fraction: own_power_fraction,
      natural_gas: current_energy_mix[:natural_gas] / fossils,
      autacry_in_percent: autacry_in_percent,
      additional_supply_ratio: additional_supply_ratio,
      non_eeg: non_eeg,
      production_consumend_in_group_kWh: production_consumend_in_group_kWh,
      consumption_without_third_party: consumption_without_third_party.to_f,
      production: production.to_f,
      consumption_eeg_reduced: consumption_eeg_reduced.to_i,
      consumption_eeg_full: consumption_eeg_full.to_i
    )
  end

  def electricity_supplier(resource:, **)
    if resource.electricity_supplier.nil?
      'Buzzn GmbH'
    else
      resource.electricity_supplier.name
    end
  end

  def self_sufficiency_report(production_consumend_in_group_kWh:, consumption_without_third_party:, **)
    if production_consumend_in_group_kWh / consumption_without_third_party * BigDecimal('100') > 100
      return BigDecimal('100')
    end

    production_consumend_in_group_kWh / consumption_without_third_party * BigDecimal('100')
  end

  def utilization_report(production_consumend_in_group_kWh:, production:, **)
    if production.zero?
      return BigDecimal('0')
    end

    if production_consumend_in_group_kWh / production * BigDecimal('100') > 100
      return BigDecimal('100')
    end

    production_consumend_in_group_kWh / production * BigDecimal('100')
  end

  def register_metas_active(register_metas:, **)
    # A register is considered active if it has at least
    # one register not decomissioned/
    register_metas.select { |m| m.registers.any? { |r| !r.decomissioned? } }
  end

  def technologies(
    resource:,
    **
  )
    technologies = {chp: 'Kraft-Wärme-Kopplung mit Blockheizkraftwerk', wind: 'Windkraftwerk', water: 'Wasserkraft', pv: 'Photovoltaik'}
    resource.power_sources.map {|s| technologies[s.to_sym]}.join ' ##'
  end

  # E18
  # Gets the production of the chp consumed within the group.
  def production_chp_consumend_in_group_kWh(
    register_metas_active:,
    date_range:,
    production_chp:,
    grid_feeding_corrected:,
    warnings:,
    **
  )
    if register_metas_active.select(&:production_chp?).none?
      return BigDecimal('0')
    end

    #chp consumption can be calculated by subtracting the chp demarcation from the chp production
    if register_metas_active.map(&:label).any? {|x| x == 'demarcation_chp'}
      return production_chp - system(
        register_metas: register_metas_active,
        date_range: date_range,
        label: :demarcation_chp,
        warnings: warnings
      )
    end

    #If no chp demarcation meter is installed, the chp demarcation can be calculated by 
    #subtracting the value of the existing demarcation meters from grid_feeding_corrected.
    #Warning: This only works if there are at least n-1 demarcation meters, where n is the number of production units.
    if register_metas_active.select(&:demarcation?).any?
      return production_chp - (grid_feeding_corrected - system(
        register_metas: register_metas_active,
        date_range: date_range,
        label: :demarcation,
        warnings: warnings
      ))
    end

    production_chp - grid_feeding_corrected
  end

  # Gets the production of the pv consumed within the group.
  def production_pv_consumend_in_group_kWh(
    register_metas_active:,
    date_range:,
    production_pv:,
    grid_feeding_corrected:,
    warnings:,
    **
  )
    if register_metas_active.select(&:production_pv?).none?
      return BigDecimal('0')
    end

    #pv consumption can be calculated by subtracting the pv demarcation from the pv production

    if register_metas_active.map(&:label).any? {|x| x == 'demarcation_pv'}
      return production_pv - system(
        register_metas: register_metas_active,
        date_range: date_range,
        label: :demarcation_pv,
        warnings: warnings
      )
    end

    #If no pv demarcation meter is installed, the pv demarcation can be calculated by 
    #subtracting the value of the existing demarcation meters from grid_feeding_corrected.
    #Warning: This only works if there are at least n-1 demarcation meters, where n is the number of production units.
    if register_metas_active.select(&:demarcation?).any?
      return production_pv -( grid_feeding_corrected - system(
        register_metas: register_metas_active,
        date_range: date_range,
        label: :demarcation,
        warnings: warnings
      ))
    end

    production_pv - grid_feeding_corrected
  end

  # Gets the production of the water consumed within the group.
  def production_water_consumend_in_group_kWh(
   register_metas_active:,
   date_range:,
   production_water:,
   grid_feeding_corrected:,
   warnings:,
   **
  )
    if register_metas_active.select(&:production_water?).none?
      return BigDecimal('0')
    end

    #water consumption can be calculated by subtracting the water demarcation from the water production

    if register_metas_active.map(&:label).any? {|x| x == 'demarcation_water'}
      return production_water - system(
        register_metas: register_metas_active,
        date_range: date_range,
        label: :demarcation_water,
        warnings: warnings
      )
    end

    #If no water demarcation meter is installed, the water demarcation can be calculated by 
    #subtracting the value of the existing demarcation meters from grid_feeding_corrected.
    #Warning: This only works if there are at least n-1 demarcation meters, where n is the number of production units.
    if register_metas_active.select(&:demarcation?).any?
      return production_water - (grid_feeding_corrected - system(
        register_metas: register_metas_active,
        date_range: date_range,
        label: :demarcation,
        warnings: warnings
      ))
    end

    production_water - grid_feeding_corrected
  end

  # Gets the production of the wind consumed within the group.
  def production_wind_consumend_in_group_kWh(
    register_metas_active:,
    date_range:,
    production_wind:,
    grid_feeding_corrected:,
    warnings:,
    **
  )
    if register_metas_active.select(&:production_wind?).none?
      return BigDecimal('0')
    end

    #wind consumption can be calculated by subtracting the wind demarcation from the pv production
    if register_metas_active.map(&:label).any? {|x| x == 'demarcation_wind'}
      return production_wind - system(
        register_metas: register_metas_active,
        date_range: date_range,
        label: :demarcation_wind,
        warnings: warnings
      )
    end

    #If no wind demarcation meter is installed, the wind demarcation can be calculated by 
    #subtracting the value of the existing demarcation meters from grid_feeding_corrected.
    #Warning: This only works if there are at least n-1 demarcation meters, where n is the number of production units.
    if register_metas_active.select(&:demarcation?).any?
      return production_wind - (grid_feeding_corrected - system(
        register_metas: register_metas_active,
        date_range: date_range,
        label: :demarcation,
        warnings: warnings
      ))
    end

    production_wind - grid_feeding_corrected
  end

  def production_consumend_in_group_kWh_by_productions(
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
  
  def production_consumend_in_group_kWh(
    production_chp:,
    production_pv:,
    production_water:,
    production_wind:,
    grid_feeding_corrected:,
    **
  )
   (production_chp + production_pv + production_water + production_wind) - grid_feeding_corrected
    
  end
  
  # E65
  def autacry_in_percent(consumption_without_third_party:, production_consumend_in_group_kWh:, warnings:, **)
    autacry = production_consumend_in_group_kWh / consumption_without_third_party * 100
    if autacry > 100
      warnings.concat ['Group had an overall higher prodaction than consumption']
      return 100
    end
    autacry
  end

  # E66
  def additional_supply_ratio(autacry_in_percent:, **)
    BigDecimal('100') - autacry_in_percent
  end

  # E34
  def renewable_eeg(paid_levy_by_local_power_giver:, eeg_quotient:, **)
    paid_levy_by_local_power_giver * eeg_quotient
  end

  # E78
  def renewable_through_eeg(renewable_eeg:, consumption_without_third_party:, **)
    renewable_eeg / consumption_without_third_party * BigDecimal('100')
  end

  # E79
  def renter_power(resource:, production_pv_consumend_in_group_kWh:, consumption_without_third_party:, **)
    if [50, 44, 47, 45, 69, 48].include? resource.id
      return production_pv_consumend_in_group_kWh / consumption_without_third_party * BigDecimal('100')
    end
    BigDecimal('0')
  end

  # E67
  def non_eeg(renewable_through_eeg:, renter_power:, **)
    BigDecimal('100') - renewable_through_eeg - renter_power
  end

  # @param consumption_own_production_wh [number] Amount of electricity
  # consumed which has been produced within the group.
  # @param grid_consumption [number]
  def lsn_producted_consumption(consumption_own_production_wh:, grid_consumption:, **)
    consumption_own_production_wh + grid_consumption
  end

  # E28
  def full_levy_ct_per_kWh(**)
    BigDecimal('6.5')
  end

  # E29
  def reduced_levy_ct_per_kWh(**)
    BigDecimal('2.7168') #2.6
  end

  # E13, E30
  def consumption_eeg_full(contracts_with_range_and_readings:, **)
    contracts_with_range_and_readings[:normal_wh]
  end

  # E14, E31
  def consumption_eeg_reduced(contracts_with_range_and_readings:, **)
    contracts_with_range_and_readings[:reduced_wh]
  end

  # E15
  def consumption_without_third_party(consumption_eeg_full:, consumption_eeg_reduced:, **)
    consumption_eeg_full + consumption_eeg_reduced
  end

  # E32
  # @return [BigDecimal] The levy paid by the local power giver.
  def paid_levy_by_local_power_giver(full_levy_ct_per_kWh:,
                                     consumption_eeg_full:,
                                     consumption_eeg_reduced:,
                                     reduced_levy_ct_per_kWh:,
                                     **)
    (full_levy_ct_per_kWh * consumption_eeg_full / BigDecimal('100') + reduced_levy_ct_per_kWh * consumption_eeg_reduced / BigDecimal('100'))
  end

  # E33
  def eeg_quotient(**)
    BigDecimal('9.421')
  end

  def co2_emmision_g_per_kwh_coal(**)
    BigDecimal('850')
  end

  def co2_emmision_g_per_kwh_gas(**)
    BigDecimal('640')
  end

  def co2_emmision_g_per_kwh_other(**)
    BigDecimal('850')
  end

  def energy_mix(**)
    {
      germany: {
        nuclear: BigDecimal('13.5'),
        coal: BigDecimal('29.0'),
        natural_gas: BigDecimal('11.9'),
        other_fossil: BigDecimal('1.3'),
        other_renewable: BigDecimal('3.9'),
        renewable_eeg: BigDecimal('40.4'),
        co2_emissions_g_per_kwh: BigDecimal('352'),
        radioactive_waste_g_per_kwh: BigDecimal('0.0004')
      },
      buzzn: {
        nuclear: BigDecimal('0.0'),
        coal: BigDecimal('0.0'),
        natural_gas: BigDecimal('18.3'),
        other_fossil: BigDecimal('0.0'),
        other_renewable: BigDecimal('21.4'),
        renewable_eeg: BigDecimal('60.3'),
        co2_emissions_g_per_kwh: BigDecimal('91'),
        radioactive_waste_g_per_kwh: BigDecimal('0.0')
      }
      # others to come
    }
  end

end
