module Buzzn::Localpool
  class CalculateEnergyClassification
    class << self
      def do_calculation(localpool, total_accounted_energy, full_renewable_energy_law_taxation, reduced_renewable_energy_law_taxation, eeg_ratio_kWh_per_euro)
        # TODO: don't take the first object, look for the appropriate object to that specific time.
        # TODO: create a contract that connects with the organization of the "grid_consumption contract"
        energy_classification_grid_consumption = localpool.registers.by_label(Register::Base::GRID_CONSUMPTION_CORRECTED).first.contracts.other_suppliers.first.contractor.energy_classifications.first
        # TODO: don't take the first object, look for the appropriate object to that specific time.
        energy_classification_germany = Organization.germany.energy_classifications.first
        # D119
        total_consumption_by_lsn = total_accounted_energy.total_consumption_by_lsn
        # F43 and D121
        known_origin = total_accounted_energy.consumption_through_chp + total_accounted_energy.grid_consumption_corrected
        # F44 and J121
        # TODO: ask Philipp about the discrepancy between consumption_through_chp/pv and the values from the Excel sheet
        unknown_origin = total_accounted_energy.consumption_through_pv
        # F6 and J119 and J154
        end_consumers = total_accounted_energy.consumption_lsn_full_eeg

        sum_ratios_from_grid_consumption = (energy_classification_grid_consumption.coal_ratio + energy_classification_grid_consumption.nuclear_ratio + energy_classification_grid_consumption.gas_ratio + energy_classification_grid_consumption.other_fossiles_ratio + energy_classification_grid_consumption.other_renewables_ratio).round(2)
        # I126
        known_origin_nuclear_energy = (total_accounted_energy.grid_consumption_corrected * energy_classification_grid_consumption.nuclear_ratio / sum_ratios_from_grid_consumption).round(2)
        # I129
        known_origin_coal_energy = (total_accounted_energy.grid_consumption_corrected * energy_classification_grid_consumption.coal_ratio / sum_ratios_from_grid_consumption).round(2)
        # I132
        known_origin_gas_energy = (total_accounted_energy.consumption_through_chp + total_accounted_energy.grid_consumption_corrected * energy_classification_grid_consumption.gas_ratio / sum_ratios_from_grid_consumption).round(2)
        # TODO: inform Philipp that this field is hard coded in the Excel sheet
        # I135
        known_origin_other_fossiles_energy = (total_accounted_energy.grid_consumption_corrected * energy_classification_grid_consumption.other_fossiles_ratio / sum_ratios_from_grid_consumption).round(2)
        # I138
        known_origin_other_renewables_energy = (total_accounted_energy.grid_consumption_corrected * energy_classification_grid_consumption.other_renewables_ratio / sum_ratios_from_grid_consumption).round(2)
        # I145
        known_origin_co2_emissions = (energy_classification_grid_consumption.co2_emission_gramm_per_kWh * total_accounted_energy.grid_consumption_corrected + 202 * total_accounted_energy.consumption_through_chp).round(2)
        # I146
        known_origin_nuclear_waste = (energy_classification_grid_consumption.nuclear_waste_miligramm_per_kWh / 1000 * total_accounted_energy.grid_consumption_corrected).round(2)
        # I 143
        known_origin_sum_energy = (known_origin_nuclear_energy + known_origin_coal_energy + known_origin_gas_energy + known_origin_other_fossiles_energy + known_origin_other_renewables_energy).round(2)
        known_origin_sum_energy_without_renewables = (known_origin_sum_energy - known_origin_other_renewables_energy).round(2)
        # F15
        energy_full_eeg_debt = (1.0 * (total_accounted_energy.consumption_through_chp + total_accounted_energy.consumption_through_pv)/total_consumption_by_lsn * end_consumers).round(2)
        # F16
        energy_reduced_eeg_debt = (1.0 * (total_accounted_energy.consumption_through_chp + total_accounted_energy.consumption_through_pv)/total_consumption_by_lsn * (total_consumption_by_lsn - end_consumers)).round(2)
        # F45 and J152
        # TODO: ask Philipp if the formula is correct as there is a double multiplication
        eeg_tax_payd = (full_renewable_energy_law_taxation / 100.0 * energy_full_eeg_debt + full_renewable_energy_law_taxation / 100.0 * reduced_renewable_energy_law_taxation / 100.0 * energy_reduced_eeg_debt + full_renewable_energy_law_taxation/100.0 * total_accounted_energy.grid_consumption_corrected).round(2)
        # J156
        ratio_renewables_with_eeg = ((eeg_tax_payd * eeg_ratio_kWh_per_euro) / total_consumption_by_lsn).round(2)
        # J159
        energy_renewables_with_eeg = (total_consumption_by_lsn * ratio_renewables_with_eeg).round(2)

        # D151
        germany_nuclear_ratio = (energy_classification_germany.nuclear_ratio * (100 / (100 - energy_classification_germany.renewables_eeg_ratio))).round(2)
        # D152
        germany_coal_ratio = (energy_classification_germany.coal_ratio * (100 / (100 - energy_classification_germany.renewables_eeg_ratio))).round(2)
        # D153
        germany_gas_ratio = (energy_classification_germany.gas_ratio * (100 / (100 - energy_classification_germany.renewables_eeg_ratio))).round(2)
        # D154
        germany_other_fossiles_ratio = (energy_classification_germany.other_fossiles_ratio * (100 / (100 - energy_classification_germany.renewables_eeg_ratio))).round(2)
        # D155
        germany_other_renewables_ratio = (energy_classification_germany.other_renewables_ratio * (100 / (100 - energy_classification_germany.renewables_eeg_ratio))).round(2)
        # D156
        germany_total_ratio = (germany_nuclear_ratio + germany_coal_ratio + germany_gas_ratio + germany_other_fossiles_ratio + germany_other_renewables_ratio).round(2)
        # D157
        germany_co2_emissions = (energy_classification_germany.co2_emission_gramm_per_kWh * (100 / (100 - energy_classification_germany.renewables_eeg_ratio))).round(2)
        # D158
        germany_nuclear_waste = (energy_classification_germany.nuclear_waste_miligramm_per_kWh * (100 / (100 - energy_classification_germany.renewables_eeg_ratio))).round(2)

        # L126
        unknown_origin_nuclear_energy = (unknown_origin * germany_nuclear_ratio / 100.0).round(2)
        # L129
        unknown_origin_coal_energy = (unknown_origin * germany_coal_ratio / 100.0).round(2)
        # L132
        unknown_origin_gas_energy = (unknown_origin * germany_gas_ratio / 100.0).round(2)
        # L135
        unknown_origin_other_fossiles_energy = (unknown_origin * germany_other_fossiles_ratio / 100.0).round(2)
        # L138
        unknown_origin_other_renewables_energy = (unknown_origin * germany_other_renewables_ratio / 100.0).round(2)
        # L143
        unknown_origin_sum_energy = (unknown_origin_nuclear_energy + unknown_origin_coal_energy + unknown_origin_gas_energy + unknown_origin_other_fossiles_energy + unknown_origin_other_renewables_energy).round(2)
        unknown_origin_sum_energy_without_renewables = (unknown_origin_sum_energy - unknown_origin_other_renewables_energy).round(2)
        # TODO: is this right? ask Philipp!
        # L141
        unknown_origin_hkn = 0
        # L145
        unknown_origin_co2_emissions = (unknown_origin_sum_energy * germany_co2_emissions).round(2)
        # L146
        unknown_origin_nuclear_waste = (unknown_origin_sum_energy * germany_nuclear_waste / 1000).round(2)

        # G126
        final_nuclear_energy_without_eeg = ((known_origin_nuclear_energy + unknown_origin_nuclear_energy) * (1 - unknown_origin_hkn * 1.0/(known_origin_sum_energy_without_renewables + unknown_origin_sum_energy_without_renewables))).round(2)
        # G126
        final_coal_energy_without_eeg = ((known_origin_coal_energy + unknown_origin_coal_energy) * (1 - unknown_origin_hkn * 1.0/(known_origin_sum_energy_without_renewables + unknown_origin_sum_energy_without_renewables))).round(2)
        # G126
        final_gas_energy_without_eeg = ((known_origin_gas_energy + unknown_origin_gas_energy) * (1 - unknown_origin_hkn * 1.0/(known_origin_sum_energy_without_renewables + unknown_origin_sum_energy_without_renewables))).round(2)
        # G126
        final_other_fossiles_energy_without_eeg = ((known_origin_other_fossiles_energy + unknown_origin_other_fossiles_energy) * (1 - unknown_origin_hkn * 1.0/(known_origin_sum_energy_without_renewables + unknown_origin_sum_energy_without_renewables))).round(2)
        # G126
        final_other_renewables_energy_without_eeg = ((known_origin_other_renewables_energy + unknown_origin_other_renewables_energy + unknown_origin_hkn)).round(2)
        # G143
        final_sum_energy_without_eeg = (final_nuclear_energy_without_eeg + final_coal_energy_without_eeg + final_gas_energy_without_eeg + final_other_fossiles_energy_without_eeg + final_other_renewables_energy_without_eeg).round(2)

        # D142 and J159
        eeg_rewarded_energy = (energy_renewables_with_eeg).round(2)
        # F142
        eeg_rewarded_ratio = (eeg_rewarded_energy * 1.0 / total_consumption_by_lsn).round(2)

        # D126
        final_nuclear_energy = (final_nuclear_energy_without_eeg * (1 - eeg_rewarded_ratio)).round(2)
        # D129
        final_coal_energy = (final_coal_energy_without_eeg * (1 - eeg_rewarded_ratio)).round(2)
        # D132
        final_gas_energy = (final_gas_energy_without_eeg * (1 - eeg_rewarded_ratio)).round(2)
        # D135
        final_other_fossiles_energy = (final_other_fossiles_energy_without_eeg * (1 - eeg_rewarded_ratio)).round(2)
        # D138
        final_other_renewables_energy = (final_other_renewables_energy_without_eeg * (1 - eeg_rewarded_ratio)).round(2)
        # D143
        final_sum_energy = (final_nuclear_energy + final_coal_energy + final_gas_energy + final_other_fossiles_energy + final_other_renewables_energy + eeg_rewarded_energy).round(2)

        # F126
        final_nuclear_ratio = (final_nuclear_energy * 1.0 / total_consumption_by_lsn).round(2)
        # F129
        final_coal_ratio = (final_coal_energy * 1.0 / total_consumption_by_lsn).round(2)
        # F132
        final_gas_ratio = (final_gas_energy * 1.0 / total_consumption_by_lsn).round(2)
        # F135
        final_other_fossiles_ratio = (final_other_fossiles_energy * 1.0 / total_consumption_by_lsn).round(2)
        # F138
        final_other_renewables_ratio = (final_other_renewables_energy * 1.0 / total_consumption_by_lsn).round(2)
        # F143
        # TODO: this must be 1 but is 1.04 in the spec ... ?!
        final_sum_ratios = (final_nuclear_ratio + final_coal_ratio + final_gas_ratio + final_other_fossiles_ratio + final_other_renewables_ratio + eeg_rewarded_ratio).round(2)

        # F145
        final_co2_emissions = ((known_origin_co2_emissions + unknown_origin_co2_emissions) / total_consumption_by_lsn * (1 - unknown_origin_hkn / (known_origin_sum_energy_without_renewables + unknown_origin_sum_energy_without_renewables)) * (1 - eeg_rewarded_ratio)).round(2)
        # F145
        final_nuclear_waste = ((known_origin_nuclear_waste + unknown_origin_nuclear_waste) / total_consumption_by_lsn * (1 - unknown_origin_hkn / (known_origin_sum_energy_without_renewables + unknown_origin_sum_energy_without_renewables)) * (1 - eeg_rewarded_ratio)).round(2)

        # TODO: think about storing these values in the database. Usually they are not needed except for the moment when we create the billings for all LSN in a LCP
        return EnergyClassification.new(tariff_name: localpool.name,
                                        nuclear_ratio: final_nuclear_ratio,
                                        coal_ratio: final_coal_ratio,
                                        gas_ratio: final_gas_ratio,
                                        other_fossiles_ratio: final_other_fossiles_ratio,
                                        renewables_eeg_ratio: eeg_rewarded_ratio,
                                        other_renewables_ratio: final_other_renewables_ratio,
                                        co2_emission_gramm_per_kWh: final_co2_emissions,
                                        nuclear_waste_miligramm_per_kWh: final_nuclear_waste * 1000.0)
      end
    end
  end
end