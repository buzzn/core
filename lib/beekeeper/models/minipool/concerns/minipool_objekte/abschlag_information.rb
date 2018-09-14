require 'active_support/concern'

class Beekeeper::Minipool::MinipoolObjekte < Beekeeper::Minipool::BaseRecord
  module AbschlagInformation

    extend ActiveSupport::Concern

    private

    def billing_detail
      bd = BillingDetail.new
      bd.reduced_power_amount = strom_reduziert_eeg
      bd.reduced_power_factor = red_eeg_satz / 100.00
      bd.automatic_abschlag_adjust = automat_abschlag_anp.positive?
      bd.automatic_abschlag_threshold = automat_abschlag_anp_schwellwert
      bd
    end

  end
end
