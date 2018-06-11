require_relative '../../constraints/person'
require_relative '../../constraints/address'
require_relative '../person'

Schemas::Transactions::Person::Create = Schemas::Support.Form(Schemas::Constraints::Person) do

  optional(:address).schema(Schemas::Constraints::Address)

end
