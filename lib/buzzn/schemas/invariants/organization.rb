require_relative '../constraints/organization'

module Schemas
  module Invariants

    Organization = Schemas::Support.Form(Schemas::Constraints::Organization)

  end
end
