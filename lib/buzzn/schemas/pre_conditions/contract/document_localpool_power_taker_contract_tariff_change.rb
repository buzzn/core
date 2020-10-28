require_relative '../person'
require_relative '../organization'
require_relative '../contract'
require './app/models/organization/general.rb'
require './app/models/person.rb'

module Schemas::PreConditions::Contract

  DocumentLocalpoolPowerTakerContractTariffChange = Schemas::Support.Schema do

    configure do
      def upcoming_tariff_present?(localpool)
        localpool.tariffs.select {|t| t.begin_date > Date.today}.any?
      end
    end

    required(:customer) do
      mtype?(Organization::General).then(schema(Schemas::PreConditions::Organization))
                                   .and(mtype?(Person).then(schema(Schemas::PreConditions::Person)))
    end

    required(:contractor) do
      mtype?(Organization::General).then(schema(Schemas::PreConditions::Organization))
                                   .and(mtype?(Person).then(schema(Schemas::PreConditions::Person)))
    end

    required(:localpool).schema do
      required(:address).filled
    end

    required(:contractor_bank_account).filled

    required(:current_tariff).filled
    required(:current_payment).filled

    required(:localpool, &:upcoming_tariff_present?)

  end

end
