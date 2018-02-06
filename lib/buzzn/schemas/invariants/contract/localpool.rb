require_relative 'base'

module Schemas
  module Invariants
    module Contract
      Localpool = Schemas::Support.Form(Base) do
        required(:localpool).filled
      end
    end
  end
end
