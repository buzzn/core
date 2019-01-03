require_relative 'localpool'
#require_relative '../../../../../app/models/contract/base'

module Schemas
  module Invariants
    module Contract

      LocalpoolProcessing = Schemas::Support.Form(Localpool) do

        required(:customer).filled
        required(:contractor).filled

        required(:id).maybe
        required(:begin_date).filled

        rule(customer: [:customer, :localpool]) do |customer, localpool|
          customer.localpool_owner?(localpool)
        end

        rule(tariffs: [:tariffs, :begin_date]) do |tariffs, begin_date|
          tariffs.cover_beginning_of_contract?(begin_date)
        end

        validate(only_active_contract: %i[localpool begin_date id]) do |localpool, begin_date, id|
          any = false
          localpool.localpool_processing_contracts.each do |lpc|
            if lpc.status(begin_date) == ::Contract::Base::ACTIVE && lpc.id != id
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
