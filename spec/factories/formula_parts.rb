FactoryGirl.define do
  factory :formula_part, class: 'Register::FormulaPart' do
    register    { FactoryGirl.create(:register_input) }
    operand     { FactoryGirl.create(:register_input) }
    operator    Register::FormulaPart.operators[:plus]
  end
end