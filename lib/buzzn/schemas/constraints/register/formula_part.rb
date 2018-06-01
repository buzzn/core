require './app/models/register/formula_part.rb'
require_relative '../register'

Schemas::Constraints::Register::FormulaPart = Schemas::Support.Form do
  required(:operator).value(included_in?: Register::FormulaPart.operators.values)
end
