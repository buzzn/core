require_relative 'localpool'

module Schemas
  module Invariants
    module Contract

      LocalpoolRegister = Schemas::Support.Form(Localpool) do

        required(:market_location).filled

      end

    end
  end
end
