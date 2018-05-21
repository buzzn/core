require_relative 'base_resource'

module Meter
  class VirtualResource < BaseResource

    model Virtual

    # TODO this is wrong here as not all virtual-meters will have formula-parts, i.e. wrong abstraction

    has_many :formula_parts, FormulaPartResource do |object|
      object.register.formula_parts
    end

  end
end
