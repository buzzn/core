require_relative '../localpool'
require_relative '../person'
require_relative '../organization'
require './app/models/organization/general.rb'
require './app/models/person.rb'

module Schemas::PreConditions::Localpool

  CreateMeteringPointOperatorContract = Schemas::Support.Schema do

    # only one localpool_processing_contract is allowed
    required(:metering_point_operator_contract).value(:none?)

    required(:address).filled
    required(:owner) do
      filled?.and(type?(Organization).then(schema(Schemas::PreConditions::Organization)).and(type?(Person).then(schema(Schemas::PreConditions::Person))))
    end
  end

end
