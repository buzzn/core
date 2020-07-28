require_relative 'localpool_register'

module Schemas
  module Invariants
    module Contract

      MeteringPointOperator = Schemas::Support.Form(Localpool) do

        required(:customer).filled
        required(:contractor).filled

        required(:id).maybe
        required(:begin_date).filled

        rule(customer: [:customer, :localpool]) do |customer, localpool|
          person = 'customer'
          customer.localpool_owner?(localpool, person)
        end

        rule(tariffs: [:tariffs, :begin_date, :end_date]) do |tariffs, begin_date, end_date|
          tariffs.cover_beginning_of_contract?(begin_date)
        end

        validate(only_active_contract: %i[localpool begin_date id]) do |localpool, begin_date, id|
          any = false
          localpool.metering_point_operator_contracts.each do |mpoc|
            if mpoc.status(begin_date) == ::Contract::Base::ACTIVE && mpoc.id != id
              any = true
            end
          end
          if any
            false
          else
            true
          end
        end

      end

    end
  end
end
