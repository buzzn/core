require_relative 'localpool'

module Schemas
  module Invariants
    module Contract

      LocalpoolRegister = Schemas::Support.Form(Localpool) do

        required(:register_meta).filled

      end

    end
  end
end
