require_relative '../localpool'
require_relative '../person'
require_relative '../organization'
require './app/models/organization/general.rb'
require './app/models/person.rb'

module Schemas::PreConditions::Localpool

  CreateLocalpoolPowerTakerContract = Schemas::Support.Schema do

    # localpool_processing_contract is required for the generation of contract numbers
    required(:localpool_processing_contract).value(:filled?)

    # that is the contractor, required for assignment during the transaction
    required(:owner) do
      filled?.and(type?(Organization).then(schema(Schemas::PreConditions::Organization)).and(type?(Person).then(schema(Schemas::PreConditions::Person))))
    end

  end

end
