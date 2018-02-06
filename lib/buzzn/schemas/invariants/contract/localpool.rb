require_relative 'base'

module Schemas
  module Invariants
    module Contract

      Localpool = Schemas::Support.Form(Base) do

        configure do
          def localpool_tariffs?(tariffs, localpool)
            localpool.nil? || (localpool.tariffs & tariffs) == tariffs
          end
        end

        required(:localpool).filled
        required(:tariffs).maybe
        rule(tariffs: [:localpool, :tariffs]) do |localpool, tariffs|
          localpool.localpool_tariffs?(tariffs)
        end
      end
    end
  end
end
