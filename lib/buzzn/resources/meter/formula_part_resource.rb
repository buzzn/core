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
      Register::BaseResource.to_resource(object.operand,
                                         security_context.register)
    end

    def type
      'meter_formula_part'
    end

  end
end
