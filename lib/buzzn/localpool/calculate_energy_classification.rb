module Buzzn::Localpool
  class CalculateEnergyClassification
    class << self
      def do_calculation(localpool, total_accounted_energy, full_renewable_energy_law_taxation, reduced_renewable_energy_law_taxation, eeg_ratio_kWh_per_euro)
        # NOTE: The commented strings are references to the Excel Sheet called "Stromkennzeichnung_LCP_berechnen"

        # TODO: don't take the first object, look for the appropriate object to that specific time.
        # TODO: create a contract that connects with the organization of the "grid_consumption contract"
        energy_classification_grid_consumption = localpool.registers.grid_consumption_corrected.first.contracts.other_suppliers.first.contractor.energy_classifications.first
        # TODO: don't take the first object, look for the appropriate object to that specific time.
        energy_classification_germany = Organization.germany.energy_classifications.first
        # D119
        total_consumption_by_lsn = total_accounted_energy.total_consumption_by_lsn
        # F43 and D121
        known_origin = total_accounted_energy.consumption_through_chp + total_accounted_energy.grid_consumption_corrected
        # F44 and J121
        unknown_origin = total_accounted_energy.consumption_through_pv
        # F6 and J119 and J154
        end_consumers = total_accounted_energy.consumption_lsn_full_eeg

        sum_ratios_from_grid_consumption = (energy_classification_grid_consumption.coal_ratio + energy_classification_grid_consumption.nuclear_ratio + energy_classification_grid_consumption.gas_ratio + energy_classification_grid_consumption.other_fossiles_ratio + energy_classification_grid_consumption.other_renewables_ratio)
        # I126
        known_origin_nuclear_energy = (total_accounted_energy.grid_consumption_corrected * energy_classification_grid_consumption.nuclear_ratio / sum_ratios_from_grid_consumption)
        # I129
        known_origin_coal_energy = (total_accounted_energy.grid_consumption_corrected * energy_classification_grid_consumption.coal_ratio / sum_ratios_from_grid_consumption)
        # I132
        known_origin_gas_energy = (total_accounted_energy.consumption_through_chp + total_accounted_energy.grid_consumption_corrected * energy_classification_grid_consumption.gas_ratio / sum_ratios_from_grid_consumption)
        # I135
        known_origin_other_fossiles_energy = (total_accounted_energy.grid_consumption_corrected * energy_classification_grid_consumption.other_fossiles_ratio / sum_ratios_from_grid_consumption)
        # I138
        known_origin_other_renewables_energy = (total_accounted_energy.grid_consumption_corrected * energy_classification_grid_consumption.other_renewables_ratio / sum_ratios_from_grid_consumption)
        # I145
        known_origin_co2_emissions = (energy_classification_grid_consumption.co2_emission_gramm_per_kWh * total_accounted_energy.grid_consumption_corrected + 202 * total_accounted_energy.consumption_through_chp)
        # I146
        known_origin_nuclear_waste = (energy_classification_grid_consumption.nuclear_waste_miligramm_per_kWh / 1000 * total_accounted_energy.grid_consumption_corrected)
        # I143
        known_origin_sum_energy = (known_origin_nuclear_energy + known_origin_coal_energy + known_origin_gas_energy + known_origin_other_fossiles_energy + known_origin_other_renewables_energy)
        known_origin_sum_energy_without_renewables = (known_origin_sum_energy - known_origin_other_renewables_energy).round(2)
        # F15
        energy_full_eeg_debt = (1.0 * (total_accounted_energy.consumption_through_chp + total_accounted_energy.consumption_through_pv)/total_consumption_by_lsn * end_consumers)
        # F16
        energy_reduced_eeg_debt = (1.0 * (total_accounted_energy.consumption_through_chp + total_accounted_energy.consumption_through_pv)/total_consumption_by_lsn * (total_consumption_by_lsn - end_consumers))
        # F45 and J152
        eeg_tax_payd = (full_renewable_energy_law_taxation / 100.0 * energy_full_eeg_debt + full_renewable_energy_law_taxation / 100.0 * reduced_renewable_energy_law_taxation / 100.0 * energy_reduced_eeg_debt + full_renewable_energy_law_taxation/100.0 * total_accounted_energy.grid_consumption_corrected)
        # J156
        ratio_renewables_with_eeg = ((eeg_tax_payd * eeg_ratio_kWh_per_euro) / total_consumption_by_lsn)
        # J159
        energy_renewables_with_eeg = (total_consumption_by_lsn * ratio_renewables_with_eeg)

        # D151
        germany_nuclear_ratio = (energy_classification_germany.nuclear_ratio * (100 / (100 - energy_classification_germany.renewables_eeg_ratio)))
        # D152
        germany_coal_ratio = (energy_classification_germany.coal_ratio * (100 / (100 - energy_classification_germany.renewables_eeg_ratio)))
        # D153
        germany_gas_ratio = (energy_classification_germany.gas_ratio * (100 / (100 - energy_classification_germany.renewables_eeg_ratio)))
        # D154
        germany_other_fossiles_ratio = (energy_classification_germany.other_fossiles_ratio * (100 / (100 - energy_classification_germany.renewables_eeg_ratio)))
        # D155
        germany_other_renewables_ratio = (energy_classification_germany.other_renewables_ratio * (100 / (100 - energy_classification_germany.renewables_eeg_ratio)))
        # D156
        germany_total_ratio = (germany_nuclear_ratio + germany_coal_ratio + germany_gas_ratio + germany_other_fossiles_ratio + germany_other_renewables_ratio)
        # D157
        germany_co2_emissions = (energy_classification_germany.co2_emission_gramm_per_kWh * (100 / (100 - energy_classification_germany.renewables_eeg_ratio)))
        # D158
        germany_nuclear_waste = (energy_classification_germany.nuclear_waste_miligramm_per_kWh * (100 / (100 - energy_classification_germany.renewables_eeg_ratio)))

        # L126
        unknown_origin_nuclear_energy = (unknown_origin * germany_nuclear_ratio / 100.0)
        # L129
        unknown_origin_coal_energy = (unknown_origin * germany_coal_ratio / 100.0)
        # L132
        unknown_origin_gas_energy = (unknown_origin * germany_gas_ratio / 100.0)
        # L135
        unknown_origin_other_fossiles_energy = (unknown_origin * germany_other_fossiles_ratio / 100.0)
        # L138
        unknown_origin_other_renewables_energy = (unknown_origin * germany_other_renewables_ratio / 100.0)
        # L143
        unknown_origin_sum_energy = (unknown_origin_nuclear_energy + unknown_origin_coal_energy + unknown_origin_gas_energy + unknown_origin_other_fossiles_energy + unknown_origin_other_renewables_energy)
        unknown_origin_sum_energy_without_renewables = (unknown_origin_sum_energy - unknown_origin_other_renewables_energy)
        # L141
        unknown_origin_hkn = 0
        # L145
        unknown_origin_co2_emissions = (unknown_origin_sum_energy * germany_co2_emissions)
        # L146
        unknown_origin_nuclear_waste = (unknown_origin_sum_energy * germany_nuclear_waste / 1000)

        # G126
        final_nuclear_energy_without_eeg = ((known_origin_nuclear_energy + unknown_origin_nuclear_energy) * (1 - unknown_origin_hkn * 1.0/(known_origin_sum_energy_without_renewables + unknown_origin_sum_energy_without_renewables)))
        # G126
        final_coal_energy_without_eeg = ((known_origin_coal_energy + unknown_origin_coal_energy) * (1 - unknown_origin_hkn * 1.0/(known_origin_sum_energy_without_renewables + unknown_origin_sum_energy_without_renewables)))
        # G126
        final_gas_energy_without_eeg = ((known_origin_gas_energy + unknown_origin_gas_energy) * (1 - unknown_origin_hkn * 1.0/(known_origin_sum_energy_without_renewables + unknown_origin_sum_energy_without_renewables)))
        # G126
        final_other_fossiles_energy_without_eeg = ((known_origin_other_fossiles_energy + unknown_origin_other_fossiles_energy) * (1 - unknown_origin_hkn * 1.0/(known_origin_sum_energy_without_renewables + unknown_origin_sum_energy_without_renewables)))
        # G126
        final_other_renewables_energy_without_eeg = ((known_origin_other_renewables_energy + unknown_origin_other_renewables_energy + unknown_origin_hkn))
        # G143
        final_sum_energy_without_eeg = (final_nuclear_energy_without_eeg + final_coal_energy_without_eeg + final_gas_energy_without_eeg + final_other_fossiles_energy_without_eeg + final_other_renewables_energy_without_eeg)

        # D142 and J159
        eeg_rewarded_energy = (energy_renewables_with_eeg)
        # F142
        eeg_rewarded_ratio = (eeg_rewarded_energy * 1.0 / total_consumption_by_lsn)

        # D126
        final_nuclear_energy = (final_nuclear_energy_without_eeg * (1 - eeg_rewarded_ratio))
        # D129
        final_coal_energy = (final_coal_energy_without_eeg * (1 - eeg_rewarded_ratio))
        # D132
        final_gas_energy = (final_gas_energy_without_eeg * (1 - eeg_rewarded_ratio))
        # D135
        final_other_fossiles_energy = (final_other_fossiles_energy_without_eeg * (1 - eeg_rewarded_ratio))
        # D138
        final_other_renewables_energy = (final_other_renewables_energy_without_eeg * (1 - eeg_rewarded_ratio))
        # D143
        final_sum_energy = (final_nuclear_energy + final_coal_energy + final_gas_energy + final_other_fossiles_energy + final_other_renewables_energy + eeg_rewarded_energy)

        # F126
        final_nuclear_ratio = (final_nuclear_energy * 1.0 / total_consumption_by_lsn)
        # F129
        final_coal_ratio = (final_coal_energy * 1.0 / total_consumption_by_lsn)
        # F132
        final_gas_ratio = (final_gas_energy * 1.0 / total_consumption_by_lsn)
        # F135
        final_other_fossiles_ratio = (final_other_fossiles_energy * 1.0 / total_consumption_by_lsn)
        # F138
        final_other_renewables_ratio = (final_other_renewables_energy * 1.0 / total_consumption_by_lsn)
        # F143
        final_sum_ratios = (final_nuclear_ratio + final_coal_ratio + final_gas_ratio + final_other_fossiles_ratio + final_other_renewables_ratio + eeg_rewarded_ratio)

        # F145
        final_co2_emissions = ((known_origin_co2_emissions + unknown_origin_co2_emissions) / total_consumption_by_lsn * (1 - unknown_origin_hkn / (known_origin_sum_energy_without_renewables + unknown_origin_sum_energy_without_renewables)) * (1 - eeg_rewarded_ratio))
        # F145
        final_nuclear_waste = ((known_origin_nuclear_waste + unknown_origin_nuclear_waste) / total_consumption_by_lsn * (1 - unknown_origin_hkn / (known_origin_sum_energy_without_renewables + unknown_origin_sum_energy_without_renewables)) * (1 - eeg_rewarded_ratio))

        # TODO: think about storing these values in the database. Usually they are not needed except for the moment when we create the billings for all LSN in a LCP
        # At the moment we use the energy_classifications table only for the suppliers for the grid consumption, but we might also do it for the localpools directly (?)
        return EnergyClassification.new(tariff_name: localpool.name,
                                        nuclear_ratio: (final_nuclear_ratio * 100).round(2),
                                        coal_ratio: (final_coal_ratio * 100).round(2),
                                        gas_ratio: (final_gas_ratio * 100).round(2),
                                        other_fossiles_ratio: (final_other_fossiles_ratio * 100).round(2),
                                        renewables_eeg_ratio: (eeg_rewarded_ratio * 100).round(2),
                                        other_renewables_ratio: (final_other_renewables_ratio * 100).round(2),
                                        co2_emission_gramm_per_kWh: final_co2_emissions.round,
                                        nuclear_waste_miligramm_per_kWh: (final_nuclear_waste * 1000.0).round(6))
      end
    end
  end
end
