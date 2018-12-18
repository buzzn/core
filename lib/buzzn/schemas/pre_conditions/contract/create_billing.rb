require_relative '../contract'

module Schemas::PreConditions::Contract

  CreateBilling = Schemas::Support.Schema do

    required(:tariffs).value(min_size?: 1)

    required(:register_meta).schema do
      required(:register).filled?
    end
  end

end
