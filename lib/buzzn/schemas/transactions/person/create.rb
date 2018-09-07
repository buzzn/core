require_relative '../../constraints/person'
require_relative '../../constraints/address'
require_relative '../person'

module Schemas::Transactions::Person

  Create = Schemas::Constraints::Person

  CreateWithAddress = Schemas::Support.Form(Create) do
    optional(:address).schema(Schemas::Constraints::Address)
  end

  AssignOrCreate = Schemas::Support.Form(Create) do
    optional(:id).value(:int?)
  end

  AssignOrCreateWithAddress = Schemas::Support.Form(CreateWithAddress) do
    optional(:id).value(:int?)
  end

end
