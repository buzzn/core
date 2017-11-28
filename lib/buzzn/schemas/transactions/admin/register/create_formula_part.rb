require_relative '../register'
require_relative '../../../constraints/register/formula_part'

Schemas::Transactions::Admin::Register::CreateFormulaPart = Schemas::Support.Form(Schemas::Constraints::Register::FormulaPart) do
  optional(:register_id).filled(:str?)
end
