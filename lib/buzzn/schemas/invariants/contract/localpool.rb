require_relative 'base'

module Schemas
  module Invariants
    module Contract

      Localpool = Schemas::Support.Form(Base) do

        configure do
          def localpool_tariffs?(tariffs, localpool)
            localpool.nil? || (localpool.tariffs & tariffs).sort == tariffs.sort
          end

          def lineup?(tariffs)
            end_date = nil
            sorted = tariffs.sort_by(&:begin_date).reverse
            sorted.all? do |tariff|
              result = end_date ? tariff.end_date == end_date : true
              end_date = tariff.begin_date
              result
            end
          end

          def cover_beginning_of_contract?(begin_date, tariffs)
            first_tariff = tariffs.min_by(&:begin_date)
            first_tariff.nil? || first_tariff.begin_date <= begin_date
          end

          def cover_ending_of_contract?(end_date, tariffs)
            last_tariff = tariffs.max do |m,n|
              result = m.end_date <=> n.end_date
              if result
                result
              else # result is nil, i.e. one end_date is nil
                m.end_date ? -1 : 1
              end
            end
            last_date = last_tariff ? last_tariff.end_date : nil
            last_date.nil? || (end_date && last_date >= end_date)
          end

          def localpool_owner?(localpool, contracting_party)
            localpool.nil? || localpool.owner == contracting_party
          end
        end

        required(:localpool).filled
        required(:tariffs).maybe

        rule(tariffs: [:localpool, :tariffs]) do |localpool, tariffs|
          localpool.localpool_tariffs?(tariffs)
        end

        rule(tariffs: [:tariffs]) do |tariffs|
          tariffs.lineup?
        end
      end

    end
  end
end
