module Buzzn::Pdfs
  class LCP_Report < Buzzn::PdfGenerator

    TEMPLATE = 'lcp_report.slim'

    def initialize(total_accounted_energy)
      super({})
      @total_accounted_energy = total_accounted_energy
      @localpool = Group::Localpool.find(total_accounted_energy.localpool_id)
    end

    def localpool
      @localpool
    end

    def lsg # Localpool Strom Geber = Localpool Power Giver
      @localpool.localpool_processing_contract.customer # may be user or organization
    end

    def total_accounted_energy
      @total_accounted_energy
    end

    def lsg_contact
      case lsg
      when User
        lsg
      when Organization
        lsg.managers.first
      end
    end

    def date
      Date.current.strftime("%d.%m.%Y")
    end

    def begin_date
      @total_accounted_energy.get_single_by_label(Buzzn::AccountedEnergy::GRID_CONSUMPTION).first_reading.timestamp.strftime("%d.%m.%Y")
    end

    def end_date
      @total_accounted_energy.get_single_by_label(Buzzn::AccountedEnergy::GRID_CONSUMPTION).last_reading.timestamp.strftime("%d.%m.%Y")
    end

    def total_production
      @total_accounted_energy.total_production
    end

    def production_chp
      @total_accounted_energy.production_chp
    end

    def production_pv
      @total_accounted_energy.production_pv
    end

    def grid_feeding_chp
      @total_accounted_energy.grid_feeding_chp
    end

    def grid_feeding_pv
      @total_accounted_energy.grid_feeding_pv
    end

    def own_consumption
      @total_accounted_energy.own_consumption
    end

    def grid_feeding_corrected
      @total_accounted_energy.get_single_by_label(Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED).value  / 1000000
    end

    def consumption_through_pv
      @total_accounted_energy.consumption_through_pv
    end

    def consumption_through_chp
      @total_accounted_energy.consumption_through_chp
    end

    def consumption_lsn_full_eeg
      @total_accounted_energy.sum_and_group_by_label[Buzzn::AccountedEnergy::CONSUMPTION_LSN_FULL_EEG] / 1000000
    end

    def consumption_lsn_reduced_eeg
      @total_accounted_energy.sum_and_group_by_label[Buzzn::AccountedEnergy::CONSUMPTION_LSN_REDUCED_EEG] / 1000000
    end

    def count_lsn_full_eeg
      # TODO: this only counts the accounted energies but NOT the number of registers. Display this information in the report
      result = 0
      @total_accounted_energy.accounted_energies.each do |accounted_energy|
        accounted_energy.label == Buzzn::AccountedEnergy::CONSUMPTION_LSN_FULL_EEG ? result += 1 : nil
      end
      result
    end

    def count_lsn_reduced_eeg
      # TODO: this only counts the accounted energies but NOT the number of registers. Display this information in the report
      result = 0
      @total_accounted_energy.accounted_energies.each do |accounted_energy|
        accounted_energy.label == Buzzn::AccountedEnergy::CONSUMPTION_LSN_REDUCED_EEG ? result += 1 : nil
      end
      result
    end

    def grid_consumption_corrected
      @total_accounted_energy.get_single_by_label(Buzzn::AccountedEnergy::GRID_CONSUMPTION_CORRECTED).value / 1000000
    end

    def consumption_third_party
      @total_accounted_energy.sum_and_group_by_label[Buzzn::AccountedEnergy::CONSUMPTION_THIRD_PARTY] / 1000000
    end

    def count_third_party
      # TODO: this only counts the accounted energies but NOT the number of registers. Display this information in the report
      result = 0
      @total_accounted_energy.accounted_energies.each do |accounted_energy|
        accounted_energy.label == Buzzn::AccountedEnergy::CONSUMPTION_THIRD_PARTY ? result += 1 : nil
      end
      result
    end

    def baseprice
      12 * @localpool.prices.valid_at(begin_date).first.baseprice_cents_per_month  / 100.0
    end

    def energyprice
      @localpool.prices.valid_at(begin_date).first.energyprice_cents_per_kilowatt_hour
    end

    def count_one_way_meter
      @localpool.one_way_meters.uniq.size
    end

    def count_two_way_meter
      @localpool.two_way_meters.uniq.size
    end

    def revenue_through_energy_selling
      ((consumption_lsn_full_eeg + consumption_lsn_reduced_eeg) * energyprice / 100.0).round(2)
    end

    def revenue_through_baseprice
      # TODO: maybe check each contract for its begin and end date to get the correct timespan with respect to full or reduced EEG
      (timespan_in_months * baseprice / 12 * (@localpool.registers.by_label(Register::Base::CONSUMPTION).size)).round(2)
    end

    def revenue_through_dso #Netzbetreiber
      (grid_feeding_chp * reward_chp_grid_feeding / 100.0 + grid_feeding_pv * reward_pv_grid_feeding / 100.0 + (production_chp - grid_feeding_chp) * reward_chp_own_consumption / 100.0 - baseprice_grid_feeding_per_year * timespan_in_months / 12).round(2)
    end

    def reward_chp_grid_feeding
      # TODO: think about storing those values or getting them via some service
      4.50
    end

    def reward_pv_grid_feeding
      # TODO: think about storing those values or getting them via some service
      12.00
    end

    def reward_chp_own_consumption
      # TODO: think about storing those values or getting them via some service
      0.00
    end

    def baseprice_grid_feeding_per_year
      # TODO: think about storing those values or getting them via some service
      84.00
    end

    def full_renewable_energy_law_taxation
      # TODO: think about storing those values or getting them via some service
      6.24
    end

    def reduced_renewable_energy_law_taxation
      # TODO: think about storing those values or getting them via some service
      2.50
    end

    def energyprice_grid_consumption
      # TODO: think about storing those values or getting them via some service
      22.27
    end

    def baseprice_grid_consumption_per_year
      # TODO: think about storing those values or getting them via some service
      84.00
    end

    def one_way_meter_cost_per_year
      # TODO: think about storing those values or getting them via some service
      12 * 3.00
    end

    def two_way_meter_cost_per_year
      # TODO: think about storing those values or getting them via some service
      12 * 6.00
    end

    def revenue_energy_business
      (revenue_through_energy_selling + revenue_through_baseprice).round(2)
    end

    def total_renewable_energy_law_taxation
      byebug
      # (consumption_lsn_full_egg - grid_consumpion_corrected * part_of_full_eeg_from_grid_consumption) * full_renewable_eeg +
      #   (consumption_lsn_reduced_egg - grid_consumpion_corrected * part_of_reduced_eeg_from_grid_consumption) * reduced_renewable_eeg
      ((consumption_lsn_full_eeg - grid_consumption_corrected * (consumption_lsn_full_eeg * 1.0 / (consumption_lsn_full_eeg + consumption_lsn_reduced_eeg))) * full_renewable_energy_law_taxation / 100 + (consumption_lsn_reduced_eeg - grid_consumption_corrected * (consumption_lsn_reduced_eeg * 1.0 / (consumption_lsn_full_eeg + consumption_lsn_reduced_eeg))) * reduced_renewable_energy_law_taxation / 100).round(2)
    end

    def total_cost_grid_consumption
      (grid_consumption_corrected * energyprice_grid_consumption / 100 + timespan_in_months * baseprice_grid_consumption_per_year / 12).round(2)
    end

    def localpool_service_cost
      (count_one_way_meter * one_way_meter_cost_per_year / 12 * timespan_in_months + count_two_way_meter * two_way_meter_cost_per_year / 12 * timespan_in_months).round(2)
    end

    def total_revenue
      (revenue_energy_business + revenue_through_dso).round(2)
    end

    def total_costs
      (total_renewable_energy_law_taxation + total_cost_grid_consumption + localpool_service_cost).round(2)
    end

    def balance
      (total_revenue - total_costs).round(2)
    end

    def timespan_in_months
      Buzzn::Localpool::ReadingCalculation.timespan_in_months(
        @total_accounted_energy.get_single_by_label(Buzzn::AccountedEnergy::GRID_CONSUMPTION).first_reading.timestamp,
        @total_accounted_energy.get_single_by_label(Buzzn::AccountedEnergy::GRID_CONSUMPTION).last_reading.timestamp)
    end
  end
end
