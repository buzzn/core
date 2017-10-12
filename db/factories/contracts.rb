FactoryGirl.define do
  factory :contract, class: 'Contract::MeteringPointOperator' do
    localpool                     { FactoryGirl.create(:localpool) }
    status                        Contract::Base.statuses[:active]
    contract_number               { generate(:mpo_contract_number) }
    slug                          { |attrs| "mpo-#{attrs[:contract_number]}" }
    signing_date                  Date.parse("2015-10-11")
    begin_date                    Date.parse("2016-01-01")
    customer                      { FactoryGirl.create(:person) }
    contractor                    { FactoryGirl.create(:organization, :with_bank_account) }
    first_master_uid              { generate(:register_uid) }
    second_master_uid             { generate(:register_uid) }
    contract_number_addition      1
    power_of_attorney             true
    terms_accepted                true
    metering_point_operator_name  "Generic metering point operator"

    before(:create) do |contract, _transients|
      %i(customer contractor).each do |identifier|
        person_bank_account = contract.send(identifier).bank_accounts.first
        contract.send("#{identifier}_bank_account=", person_bank_account) if person_bank_account.present?
      end
    end
  end

  trait :metering_point_operator do
    contract_number { generate(:mpo_contract_number) }
    initialize_with { Contract::MeteringPointOperator.new } # a slight hack to define a trait of contract, but use a different subclass
  end

  trait :localpool_processing do
    # FIXME: clarify and adapt contract number format
    contract_number { generate(:mpo_contract_number) }
    initialize_with { Contract::LocalpoolProcessing.new } # a slight hack to define a trait of contract, but use a different subclass
  end

  trait :localpool_powertaker do
    contract_number { generate(:lpt_contract_number) }
    initialize_with { Contract::LocalpoolPowerTaker.new } # a slight hack to define a trait of contract, but use a different subclass
    forecast_kwh_pa 1000
    customer        { FactoryGirl.create(:person, :powertaker, :with_bank_account) }
    contractor      { FactoryGirl.create(:person, :with_bank_account) }
    before(:create) do |contract, _transients|
      unless contract.register
        meter = FactoryGirl.create(:meter_real, :one_way, group: contract.localpool)
        contract.register = meter.registers.first
      end
    end
  end
end
