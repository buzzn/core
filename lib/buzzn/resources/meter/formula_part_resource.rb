require_relative '../register/base_resource'
module Meter
  class FormulaPartResource < Buzzn::Resource::Entity

    model Register::FormulaPart

    attributes :operator

    #TODO: do something like
    # has_one :register, Register::BaseResource { object.operand }

    # on admin UI we use the virtual meter to manage the virtual registers
    # IMO: a bit confusing for development and sooner or later to user
    def register
      to_resource(object.operand,
                  permissions.register,
                  Register::BaseResource)
    end

    def type
      'meter_formula_part'
    end
  end
end
