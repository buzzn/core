FactoryGirl.define do
  factory :accounting_entry, class: 'Accounting::Entry' do
    amount { rand(1337) }
    comment { FFaker::Lorem.word }
    external_reference { FFaker::Lorem.word }
  end
end
