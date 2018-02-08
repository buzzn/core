require_relative 'localpool'

module Schemas
  module Invariants
    module Contract
      LocalpoolProcessing = Schemas::Support.Form(Localpool) do

        required(:customer).filled
        required(:contractor).filled

        rule(customer: [:customer, :localpool]) do |customer, localpool|
          customer.localpool_owner?(localpool)
        end

        rule(tariffs: [:tariffs, :begin_date, :end_date]) do |tariffs, begin_date, end_date|
          tariffs.cover_beginning_of_contract?(begin_date).and(tariffs.cover_ending_of_contract?(end_date))
        end
      end
    end
  end
end
