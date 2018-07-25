require_relative '../contract'
require_relative '../person'
require_relative '../organization'
require './app/models/organization/general.rb'
require './app/models/person.rb'

module Schemas::PreConditions::Contract

  LocalpoolProcessingContractCreate = Schemas::Support.Schema do

    # only one localpool_processing_contract is allowed
    required(:localpool_processing_contract).value(:none?)

    # that is the customer
    required(:owner) do
      filled?.and(type?(Organization).then(schema(Schemas::PreConditions::Organization)).and(type?(Person).then(schema(Schemas::PreConditions::Person))))
    end

  end

end
