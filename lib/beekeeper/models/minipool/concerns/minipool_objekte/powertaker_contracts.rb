require 'active_support/concern'

class Beekeeper::Minipool::MinipoolObjekte < Beekeeper::Minipool::BaseRecord
  module PowertakerContracts

    extend ActiveSupport::Concern

    private

    def powertaker_contracts
      minipool_sns.map(&:converted_attributes)
    end

    def third_party_contracts
      minipool_sns_3.collect do |sn|
        sn.converted_attributes.slice(:contract_number,
                                      :contract_number_addition,
                                      :signing_date,
                                      :begin_date,
                                      :termination_date,
                                      :end_date,
                                      :buzznid)
      end
    end

    # get the powertakers ("sn" == Stromnehmer) of this localpool
    def minipool_sns
      @minipool_sns ||= Beekeeper::Minipool::MinipoolSn.where(vertragsnummer: vertragsnummer, drittbelieferung: 0)
    end

    def minipool_sns_3
      @minipool_sns_3 ||= Beekeeper::Minipool::MinipoolSn.where(vertragsnummer: vertragsnummer, drittbelieferung: 1)
    end
  end
end
