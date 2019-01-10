require_relative '../localpool'

module Schemas::Transactions

  Admin::Localpool::AssignGapContractTariffs = Schemas::Support.Form(Schemas::Transactions::Update) do
    required(:tariff_ids).value(type?: Array) { each(:int?) }
  end

end
