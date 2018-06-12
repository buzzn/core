require_relative 'update'
require_relative '../../address/update'

module Schemas::Transactions::Admin::Localpool

  UpdateWithAddress = Schemas::Support.Form(Update) do
    optional(:address).schema(Schemas::Transactions::Address::Update)
  end

end
