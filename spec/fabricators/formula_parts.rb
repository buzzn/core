Fabricator(:new_formula_part, class_name: 'Register::FormulaPart') do
  register    { Fabricate(:new_register_input) }
  operand     { Fabricate(:new_register_input) }
  operator    Register::FormulaPart.operators[:plus]
end
