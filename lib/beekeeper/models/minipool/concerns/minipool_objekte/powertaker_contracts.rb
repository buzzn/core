require 'active_support/concern'

class Beekeeper::Minipool::MinipoolObjekte < Beekeeper::Minipool::BaseRecord
  module PowertakerContracts

    extend ActiveSupport::Concern

    private

    def powertaker_contracts
      minipool_sns.map(&:converted_attributes)
    end

    # get the powertakers ("sn" == Stromnehmer) of this localpool
    # FIXME: must still exclude all contracts where powertaker is an organization, for that a join is needed
    def minipool_sns
      @minipool_sns ||= Beekeeper::Minipool::MinipoolSn.where(vertragsnummer: vertragsnummer, drittbelieferung: 0)
    end
  end
end
