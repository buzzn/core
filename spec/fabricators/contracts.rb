Fabricator(:new_contract, class_name: 'Contract::MeteringPointOperator') do
  localpool                     { Fabricate(:new_localpool) }
  status                        Contract::Base.statuses[:active]
  contract_number               { sequence(:mpo_contract_number, 90012) }
  slug                          { |attrs| "mpo-#{attrs[:contract_number]}" }
  signing_date                  Date.parse("2015-10-11")
  begin_date                    Date.parse("2016-01-01")
  customer                      { Fabricate(:new_person, first_name: "Wolfgang") }
  contractor                    { Fabricate(:new_organization) }
  first_master_uid              { sequence(:uid, 90688251510000000000002677114) }
  second_master_uid             { sequence(:uid) }
  contract_number_addition      1
  power_of_attorney             true
  terms_accepted                true
  metering_point_operator_name  "Generic metering point operator"

  before_create do |contract|
    contract.contractor_bank_account = Fabricate(:bank_account, contracting_party: contract.contractor)
    contract.customer_bank_account = Fabricate(:bank_account, contracting_party: contract.customer)
  end
end
