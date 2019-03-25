require_relative '../person'
require_relative '../organization'
require_relative '../contract'
require './app/models/organization/general.rb'
require './app/models/person.rb'

module Schemas::PreConditions::Contract

  DocumentLocalpoolPowerTakerContractConfirmationA02 = Schemas::Support.Schema do

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

  end

end
