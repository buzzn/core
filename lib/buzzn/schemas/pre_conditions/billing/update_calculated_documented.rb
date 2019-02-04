require_relative 'update'

module Schemas::PreConditions::Billing::Update

  CalculatedDocumented = Schemas::Support.Schema do

    required(:status).eql?('calculated')

    required(:contract).schema do
      required(:payments).value(min_size?: 1)
    end

  end

end
