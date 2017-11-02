require_relative '../register'
require_relative '../../../constraints/register/formula_part'

Schemas::Transactions::Admin::Register::UpdateFormulaPart = Buzzn::Schemas.Form(Schemas::Transactions::Update) do
  optional(:operator).value(included_in?: Register::FormulaPart.operators.values)
  optional(:register_id).filled(:str?)
end
