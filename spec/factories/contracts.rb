FactoryGirl.define do
  factory :contract, class: 'Contract::MeteringPointOperator' do
    localpool                     { FactoryGirl.create(:localpool) }
    status                        Contract::Base.statuses[:active]
    sequence(:contract_number, 90012)
    slug                          { |attrs| "mpo-#{attrs[:contract_number]}" }
    signing_date                  Date.parse("2015-10-11")
    begin_date                    Date.parse("2016-01-01")
    customer                      { FactoryGirl.create(:person, first_name: "Wolfgang") }
    contractor                    { FactoryGirl.create(:organization) }
    sequence(:first_master_uid, 90688251510000000000002677114)
    sequence(:second_master_uid)
    contract_number_addition      1
    power_of_attorney             true
    terms_accepted                true
    metering_point_operator_name  "Generic metering point operator"

    before(:create) do |contract, _transients|
      # TODO: reuse the contracting party's account here
      contract.contractor_bank_account = FactoryGirl.create(:bank_account, contracting_party: contract.contractor)
      contract.customer_bank_account   = FactoryGirl.create(:bank_account, contracting_party: contract.customer)
    end
  end
end