module Meter
  class FormulaPartResource < Buzzn::Resource::Entity

    model Register::FormulaPart

    attributes :operator

    # on admin UI we use the virtual meter to manage the virtual registers
    # IMO: a bit confusing for development and sooner or later to user
    has_one :register, &:operand

    def type
      'meter_formula_part'
    end

  end
end
