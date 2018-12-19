require_relative '../localpool_power_taker'

module Schemas::Transactions

  Admin::Contract::Localpool::PowerTaker::AssignTariffs = Schemas::Support.Form(Schemas::Transactions::Update) do
    required(:tariff_ids).value(type?: Array) { each(:int?) }
  end

end
