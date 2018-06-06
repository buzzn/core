require './app/models/address.rb'
require_relative '../address'

Schemas::Transactions::Address::Update = Schemas::Support.Form(Schemas::Transactions::Update) do
  optional(:street).filled(:str?, max_size?: 64)
  optional(:zip).filled(:str?, max_size?: 16)
  optional(:city).filled(:str?, max_size?: 64)
  optional(:country).value(included_in?: Address.countries.values)
  optional(:addition).filled(:str?, max_size?: 64)
end
