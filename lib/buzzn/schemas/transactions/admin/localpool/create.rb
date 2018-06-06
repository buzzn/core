require_relative '../../../constraints/group'
require_relative '../../../constraints/address'
require_relative '../localpool'

Schemas::Transactions::Admin::Localpool::Create = Schemas::Support.Form(Schemas::Constraints::Group) do

  optional(:address).schema(Schemas::Constraints::Address)

end
