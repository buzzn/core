module Buzzn::Localpool
  class TotalAccountedEnergy

    attr_reader :localpool

    NONE = :none
    PV = :pv
    CHP = :chp

    def initialize(localpool)
      @localpool = localpool
      @map = {}
    end

    def accounted_energies
      @map.values.flatten
    end

    def add(accounted_energy)
      case accounted_energy.label
      when *Buzzn::AccountedEnergy::SINGLE_LABELS
        if @map[accounted_energy.label]
          raise ArgumentError.new("label #{accounted_energy.label} already set")
        end
        @map[accounted_energy.label] = accounted_energy
      when *Buzzn::AccountedEnergy::MULTI_LABELS
        (@map[accounted_energy.label] ||= []) << accounted_energy
      when NilClass
        raise ArgumentError.new('accounted energy needs label')
      else
        raise ArgumentError.new("unknown label #{accounted_energy.label}")
      end
    end

    def [](label)
      @map[label]
    end
    alias :get :[]

    def sum(label)
      result = Buzzn::Math::Energy.zero
      get(label).each do |item|
        result += item.value
      end
      result
    end

    def grid_feeding_chp
      result =
        case demarcation_type
        when CHP
          get(Buzzn::AccountedEnergy::DEMARCATION_CHP).value
        when PV
          get(Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED).value - get(Buzzn::AccountedEnergy::DEMARCATION_PV).value
        when NONE
          generator_type = localpool.energy_generator_type
          if generator_type == Group::Base::CHP
            get(Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED).value
          else
            Buzzn::Math::Energy.zero
          end
        else
          raise 'bug'
        end
      result > Buzzn::Math::Energy.zero ? result : Buzzn::Math::Energy.zero
    end

    def grid_feeding_pv
      result =
        case demarcation_type
        when PV
          get(Buzzn::AccountedEnergy::DEMARCATION_PV).value
        when CHP
          get(Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED).value - get(Buzzn::AccountedEnergy::DEMARCATION_CHP).value
        when NONE
          generator_type = localpool.energy_generator_type
          if generator_type == Group::Base::PV
            get(Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED).value
          else
            Buzzn::Math::Energy.zero
          end
        else
          raise 'bug'
        end
      result > Buzzn::Math::Energy.zero ? result : Buzzn::Math::Energy.zero
    end

    def consumption_through_chp
      result =
        case demarcation_type
        when CHP
          production_chp - get(Buzzn::AccountedEnergy::DEMARCATION_CHP).value
        when PV
          production_chp - get(Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED).value + get(Buzzn::AccountedEnergy::DEMARCATION_PV).value
        when NONE
          production_chp - get(Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED).value
        else
          raise 'bug'
        end
      result > Buzzn::Math::Energy.zero ? result : Buzzn::Math::Energy.zero
    end

    def consumption_through_pv
      result =
        case demarcation_type
        when PV
          production_pv - get(Buzzn::AccountedEnergy::DEMARCATION_PV).value
        when CHP
          production_pv - get(Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED).value + get(Buzzn::AccountedEnergy::DEMARCATION_CHP).value
        when NONE
          production_pv - get(Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED).value
        else
          raise 'bug'
        end
      result > Buzzn::Math::Energy.zero ? result : Buzzn::Math::Energy.zero
    end

    def own_consumption
      total_production - get(Buzzn::AccountedEnergy::GRID_FEEDING).value
    end

    def total_production
      production_pv + production_chp
    end

    def production_pv
      sum(Buzzn::AccountedEnergy::PRODUCTION_PV) 
    end

    def production_chp
      sum(Buzzn::AccountedEnergy::PRODUCTION_CHP) 
    end

    def total_consumption_power_taker
      consumption_power_taker_full_eeg + consumption_power_taker_reduced_eeg
    end

    def consumption_power_taker_full_eeg
      sum(Buzzn::AccountedEnergy::CONSUMPTION_LSN_FULL_EEG)
    end

    def consumption_power_taker_reduced_eeg
      sum(Buzzn::AccountedEnergy::CONSUMPTION_LSN_REDUCED_EEG)
    end

    def count_power_taker_full_eeg
      # this only counts the accounted energies but NOT the number of registers!
      @map[Buzzn::AccountedEnergy::CONSUMPTION_LSN_FULL_EEG].size
    end

    def count_power_taker_reduced_eeg
      # this only counts the accounted energies but NOT the number of registers!
      @map[Buzzn::AccountedEnergy::CONSUMPTION_LSN_REDUCED_EEG].size
    end

    def grid_consumption_corrected
      get(Buzzn::AccountedEnergy::GRID_CONSUMPTION_CORRECTED).value
    end

    def consumption_third_party
      sum(Buzzn::AccountedEnergy::CONSUMPTION_THIRD_PARTY)
    end

    def count_third_party
      # TODO: this only counts the accounted energies but NOT the number of registers. Display this information in the report
      @map[Buzzn::AccountedEnergy::CONSUMPTION_THIRD_PARTY].size
    end

    def grid_feeding_corrected
      get(Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED).value
    end

    private
    
    def demarcation_type
      demarcation_chp = get(Buzzn::AccountedEnergy::DEMARCATION_CHP)
      demarcation_pv = get(Buzzn::AccountedEnergy::DEMARCATION_PV)
      if demarcation_chp && demarcation_pv
        raise ArgumentError.new('can not determine demarcation type')
      end
      if demarcation_pv.nil? && demarcation_chp.nil?
        NONE
      elsif demarcation_pv.nil?
        PV
      else
        CHP
      end
    end

  end
end
