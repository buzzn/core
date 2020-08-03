require_relative 'localpool_register'

module Schemas
  module Invariants
    module Contract

      LocalpoolPowerTaker = Schemas::Support.Form(LocalpoolRegister) do

        required(:customer).filled
        required(:contractor).filled

        optional(:id).filled

        rule(contractor: [:contractor, :localpool]) do |contractor, localpool|
          contractor.localpool_owner?(localpool)
        end

        rule(tariffs: [:tariffs, :begin_date]) do |tariffs, begin_date|
          errors.add(:begin_date, IS_MISSING) unless begin_date
          tariffs.cover_beginning_of_contract?(begin_date)
        end

        validate(no_other_contract_in_range: [:id, :register_meta, :begin_date]) do |this_contract_id, register_meta, begin_date|
          if begin_date.nil?
            true
          else
            contracts = register_meta.contracts.at(begin_date).to_a
            unless this_contract_id.nil?
              contracts.reject! {|x| x.id == this_contract_id}
            end
            contracts.length.zero?
          end
        end

      end

    end
  end
end
