FactoryGirl.define do
  factory :contract, class: 'Contract::MeteringPointOperator' do
    localpool                     { FactoryGirl.create(:localpool) }
    status                        Contract::Base.statuses[:active]
    contract_number               { generate(:mpo_contract_number) }
    slug                          { |attrs| "mpo-#{attrs[:contract_number]}" }
    signing_date                  Date.parse("2015-10-11")
    begin_date                    Date.parse("2016-01-01")
    customer                      { FactoryGirl.create(:person, first_name: "Wolfgang") }
    contractor                    { FactoryGirl.create(:organization) }
    first_master_uid              { generate(:register_uid) }
    second_master_uid             { generate(:register_uid) }
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