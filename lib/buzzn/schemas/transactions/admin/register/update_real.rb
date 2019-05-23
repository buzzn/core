require_relative '../register'

Schemas::Transactions::Admin::Register::UpdateReal = Schemas::Support.Form(Schemas::Transactions::Update) do
  # this should either
  # reassign (id is present)
  # create a new Register::Meta (rest is present) which is then assigned
  # nil it
  optional(:meta).schema(Schemas::Transactions::Admin::Register::CreateMetaLoose)
end
