require_relative '../pre_conditions'

module Schemas::PreConditions

  Person = Schemas::Support.Schema do
    required(:address).filled
  end

end
