module Meter
  class VirtualResource < BaseResource

    model Virtual

    has_many :formular_parts

    def formula_parts
      to_collection(object.register.formula_parts,
                    permissions.formula_parts,
                    FormularPartResource)
    end
  end
end
