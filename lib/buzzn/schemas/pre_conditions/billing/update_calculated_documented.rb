require_relative 'update'

module Schemas::PreConditions::Billing::Update

  CalculatedDocumented = Schemas::Support.Schema do

    required(:status).eql?('calculated')

    required(:contract).schema do
      required(:current_tariff).filled
      required(:current_payment).filled
    end

  end

end