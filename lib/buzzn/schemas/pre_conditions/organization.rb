require_relative '../pre_conditions'

module Schemas::PreConditions

  Organization = Schemas::Support.Schema do
    required(:legal_representation).filled
    required(:address).filled
  end

end
