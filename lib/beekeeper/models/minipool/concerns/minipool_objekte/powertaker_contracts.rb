require 'active_support/concern'

class Beekeeper::Minipool::MinipoolObjekte < Beekeeper::Minipool::BaseRecord
  module PowertakerContracts

    extend ActiveSupport::Concern

    private

    def powertaker_contracts
      minipool_sns.map(&:converted_attributes)
    end

    def minipool_sns
      @minipool_sns ||= Beekeeper::Minipool::MinipoolSn.where(vertragsnummer: vertragsnummer)
    end
  end
end
