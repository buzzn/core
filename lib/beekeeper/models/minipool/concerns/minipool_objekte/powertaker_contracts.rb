require 'active_support/concern'

class Beekeeper::Minipool::MinipoolObjekte < Beekeeper::Minipool::BaseRecord
  module PowertakerContracts

    extend ActiveSupport::Concern

    private

    def powertaker_contracts
      minipool_sns.select(&:person?).map(&:converted_attributes)
    end

    # get the powertakers ("sn" == Stromnehmer) of this localpool
    def minipool_sns
      @minipool_sns ||= Beekeeper::Minipool::MinipoolSn.where(vertragsnummer: vertragsnummer, drittbelieferung: 0)
    end
  end
end