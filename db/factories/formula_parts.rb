FactoryGirl.define do
  factory :formula_part, class: 'Register::FormulaPart' do
    register    { FactoryGirl.build(:register, :input) }
    operand     { FactoryGirl.build(:register, :input) }
    operator    Register::FormulaPart.operators[:plus]
  end

  trait :plus do
    operator    Register::FormulaPart.operators[:plus]
  end

  trait :minus do
    operator    Register::FormulaPart.operators[:minus]
  end
end
