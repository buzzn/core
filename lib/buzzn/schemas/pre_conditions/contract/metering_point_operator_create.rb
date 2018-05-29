require_relative '../contract'
require_relative '../person'
require_relative '../organization'

module Schemas::PreConditions::Contract

  MeteringPointOperatorCreate = Schemas::Support.Schema do

    required(:address).filled
    required(:owner) do
      filled?.and(
       type?(Organization).then schema(Schemas::PreConditions::Organization)).and(
        type?(Person).then schema(Schemas::PreConditions::Person))
    end
  end

end
