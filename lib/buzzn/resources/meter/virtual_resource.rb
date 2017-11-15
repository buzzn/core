module Meter
  class VirtualResource < BaseResource

    model Virtual

    # TODO use something like this
    # has_many :formula_parts, FormulaPartResource { object.register.formula_parts }
    def formula_parts
      to_collection(object.register.formula_parts,
                    permissions.formula_parts,
                    FormulaPartResource)
    end
  end
end
