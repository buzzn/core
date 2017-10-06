FactoryGirl.define do
  factory :formula_part, class: 'Register::FormulaPart' do
    register    { FactoryGirl.create(:register, :input) }
    operand     { FactoryGirl.create(:register, :input) }
    operator    Register::FormulaPart.operators[:plus]
  end
end