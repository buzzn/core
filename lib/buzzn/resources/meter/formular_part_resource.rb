module Meter
  class FormularPartResource < Buzzn::Resource::Entity

    model Register::FormulaPart

    attributes :operator

    has_one :register

    def register
      to_resource(object.operand,
                  permissions.register,
                  # assuming Register::Real for the time being
                  Register::RealResource)
    end

    def type
      'meter_formula_part'
    end
  end
end
