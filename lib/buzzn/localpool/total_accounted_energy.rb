module Buzzn::Localpool
  class TotalAccountedEnergy
    attr_reader :localpool_id, :accounted_energies

    def initialize(localpool_id)
      @localpool_id = localpool_id
      @accounted_energies = []
    end

    def add(accounted_energy)
      @accounted_energies << accounted_energy
    end

    def get_by_label(*labels)
      result = {}
      labels.flatten.each do |label|
        label_result = []
        accounted_energies.each do |accounted_energy|
          if accounted_energy.label == label
            label_result << accounted_energy
          end
        end
        result[label] = label_result
      end
      return result
    end

    def get_single_by_label(label)
      accounted_energies_hash = get_by_label(label)
      if accounted_energies_hash[label].size > 1
        raise ArgumentError.new("Label #{label} may only occur once in the list.")
      end
      return accounted_energies_hash[label].first
    end

    def sum_and_group_by_label
      result = {}
      all_labels = Buzzn::AccountedEnergy.labels
      energies_by_label = get_by_label(all_labels)
      all_labels.each do |label|
        sum_by_label = 0
        energies_by_label[label].each do |accounted_energy|
          sum_by_label += accounted_energy.value
        end
        result[label] = sum_by_label
      end
      return result
    end

    def grid_feeding_chp
      result = 0
      case demarcation_type
      when :demarcation_chp
        result = get_single_by_label(Buzzn::AccountedEnergy::DEMARCATION_CHP).value
      when :demarcation_pv
        result = get_single_by_label(Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED).value - get_single_by_label(Buzzn::AccountedEnergy::DEMARCATION_PV).value
      else
        generator_type = Group::Localpool.find(localpool_id).energy_generator_type
        if generator_type == Group::Base::CHP
          result = get_single_by_label(Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED).value
        end
        result = 0
      end
      return result > 0 ? result / 1000 : 0
    end

    def grid_feeding_pv
      result = 0
      case demarcation_type
      when :demarcation_pv
        result = get_single_by_label(Buzzn::AccountedEnergy::DEMARCATION_PV).value
      when :demarcation_chp
        result = get_single_by_label(Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED).value - get_single_by_label(Buzzn::AccountedEnergy::DEMARCATION_CHP).value
      else
        generator_type = Group::Localpool.find(localpool_id).energy_generator_type
        if generator_type == Group::Base::PV
          result = get_single_by_label(Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED).value
        end
        result = 0
      end
      return result > 0 ? result / 1000 : 0
    end

    def consumption_through_chp
      result = 0
      case demarcation_type
      when :demarcation_chp
        result = production_chp - get_single_by_label(Buzzn::AccountedEnergy::DEMARCATION_CHP).value
      when :demarcation_pv
        result = production_chp - get_single_by_label(Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED).value + get_single_by_label(Buzzn::AccountedEnergy::DEMARCATION_PV).value
      else
        result = production_chp - get_single_by_label(Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED).value
      end
      return result > 0 ? result / 1000 : 0
    end

    def consumption_through_pv
      result = 0
      case demarcation_type
      when :demarcation_pv
        result = production_pv - get_single_by_label(Buzzn::AccountedEnergy::DEMARCATION_PV).value
      when :demarcation_chp
        result = production_pv - get_single_by_label(Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED).value + get_single_by_label(Buzzn::AccountedEnergy::DEMARCATION_CHP).value
      else
        result = production_pv - get_single_by_label(Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED).value
      end
      return result > 0 ? result / 1000 : 0
    end

    def demarcation_type
      demarcation_chp = get_single_by_label(Buzzn::AccountedEnergy::DEMARCATION_CHP)
      demarcation_pv = get_single_by_label(Buzzn::AccountedEnergy::DEMARCATION_PV)
      if demarcation_chp.nil?
        if demarcation_pv.nil?
          return :none
        end
        return :demarcation_pv
      end
      return :demarcation_chp
    end

    def own_consumption
      total_production - get_single_by_label(Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED).value / 1000
    end

    def total_production
      sums = sum_and_group_by_label
      (sums[Buzzn::AccountedEnergy::PRODUCTION_PV] + sums[Buzzn::AccountedEnergy::PRODUCTION_CHP]) / 1000
    end

    def production_pv
      sum_and_group_by_label[Buzzn::AccountedEnergy::PRODUCTION_PV]  / 1000
    end

    def production_chp
      sum_and_group_by_label[Buzzn::AccountedEnergy::PRODUCTION_CHP]  / 1000
    end

    def total_consumption_by_lsn
      sums = sum_and_group_by_label
      (sums[Buzzn::AccountedEnergy::CONSUMPTION_LSN_FULL_EEG] + sums[Buzzn::AccountedEnergy::CONSUMPTION_LSN_REDUCED_EEG]) / 1000
    end
  end
end