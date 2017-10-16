FactoryGirl.define do
  factory :payment, class: 'Contract::Payment' do
    price_cents  55_00
    begin_date   Date.parse("2016-01-01")
    cycle        Contract::Payment::MONTHLY
    source       Contract::Payment::CALCULATED

    before(:create) do |payment, _transients|
      payment.contract ||= FactoryGirl.create(:contract, :metering_point_operator)
    end
  end
end
