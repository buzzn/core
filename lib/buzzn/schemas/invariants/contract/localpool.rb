require_relative 'base'

module Schemas
  module Invariants
    module Contract

      Localpool = Schemas::Support.Form(Base) do

        configure do
          def localpool_tariffs?(tariffs, localpool)
            localpool.nil? || (localpool.tariffs & tariffs).sort == tariffs.sort
          end

          def cover_beginning_of_contract?(begin_date, tariffs)
            first_tariff = tariffs.min_by(&:begin_date)
            first_tariff.nil? || first_tariff.begin_date <= begin_date
          end

          def localpool_owner?(localpool, contracting_party)
            localpool.nil? || localpool.owner == contracting_party.model
          end
        end

        required(:localpool).filled
        required(:tariffs).maybe

        rule(tariffs: [:localpool, :tariffs]) do |localpool, tariffs|
          localpool.localpool_tariffs?(tariffs).and(tariffs.unique_begin_date?)
        end

      end

    end
  end
end
