FactoryGirl.define do
  factory :payment, class: 'Contract::Payment' do
    price_cents  55_00
    begin_date   Date.parse('2016-01-01')
    energy_consumption_kwh_pa 1337
    cycle        Contract::Payment.cycles[:monthly]

    before(:create) do |payment, _evaluator|
      payment.contract ||= FactoryGirl.build(:contract)
    end
  end
end
