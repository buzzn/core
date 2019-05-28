require_relative 'update'

module Schemas::PreConditions::Billing::Update

  CalculatedDocumented = Schemas::Support.Schema do

    required(:status).eql?('calculated')

    configure do
      def active_localpool_processing_contract_at_begin?(begin_date, contract)
        !contract.localpool.active_localpool_processing_contract(begin_date).nil?
      end
    end

    required(:contract).schema do
      required(:current_tariff).filled
      required(:current_payment).filled

      required(:localpool).schema do
        required(:fake_stats).filled
      end
    end

    required(:begin_date).filled

    rule(localpool_processing_contract: [:contract, :begin_date]) do |contract, begin_date|
      contract.active_localpool_processing_contract_at_begin?(begin_date)
    end

  end

end
