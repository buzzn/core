module Buzzn::Pdfs
  class LCP_Report < PdfGenerator

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
      Date.current
    end

    def begin_date
      @total_accounted_energy.accounted_energies.get_single_by_label(Buzzn::TotalAccountedEnergy::GRID_CONSUMPTION).first_reading.timestamp
    end

    def end_date
      @total_accounted_energy.accounted_energies.get_single_by_label(Buzzn::TotalAccountedEnergy::GRID_CONSUMPTION).last_reading.timestamp
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

    def own_consumption
      @total_accounted_energy.own_consumption
    end

    def grid_feeding_corrected
      @total_accounted_energy.get_single_by_label(Buzzn::AccountedEnergy::GRID_FEEDING_CORRECTED).value
    end
  end
end
