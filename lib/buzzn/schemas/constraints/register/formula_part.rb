require_relative '../register'

Schemas::Constraints::Register::FormulaPart = Buzzn::Schemas.Form do
  required(:operator).value(included_in?: Register::FormulaPart.operators.values)
end
