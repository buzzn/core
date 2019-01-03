require_relative 'localpool_register'

module Schemas
  module Invariants
    module Contract

      LocalpoolPowerTaker = Schemas::Support.Form(LocalpoolRegister) do

        required(:customer).filled
        required(:contractor).filled

        rule(contractor: [:contractor, :localpool]) do |contractor, localpool|
          contractor.localpool_owner?(localpool)
        end

        rule(tariffs: [:tariffs, :begin_date]) do |tariffs, begin_date|
          tariffs.cover_beginning_of_contract?(begin_date)
        end
      end

    end
  end
end
