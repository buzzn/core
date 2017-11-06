FactoryGirl.define do
  factory :contract, class: 'Contract::MeteringPointOperator' do
    localpool                     { FactoryGirl.build(:localpool) }
    contract_number               { generate(:metering_point_operator_contract_nr) }
    slug                          { |attrs| "mpo-#{attrs[:contract_number]}" }
    signing_date                  Date.parse("2015-10-11")
    begin_date                    Date.parse("2016-01-01")
    customer                      { FactoryGirl.build(:person, :with_bank_account) }
    contractor                    { FactoryGirl.build(:organization, :with_bank_account) }
    contract_number_addition      1
    power_of_attorney             true
    metering_point_operator_name  "Generic metering point operator"

    before(:create) do |contract, _evaluator|
      %i(customer contractor).each do |identifier|
        person_bank_account = contract.send(identifier).bank_accounts.first
        contract.send("#{identifier}_bank_account=", person_bank_account) if person_bank_account.present?
      end
    end
  end

  trait :metering_point_operator do
    contract_number { generate(:metering_point_operator_contract_nr) }
    initialize_with { Contract::MeteringPointOperator.new }
  end

  trait :power_taker do
    contract_number { generate(:power_taker_contract_nr) }
  end

  trait :power_giver do
    contract_number { generate(:power_giver_contract_nr) }
  end

  trait :localpool_processing do
    contract_number { generate(:localpool_processing_contract_nr) }
    initialize_with { Contract::LocalpoolProcessing.new }
  end

  trait :localpool_powertaker do
    contract_number { generate(:localpool_power_taker_contract_nr) }
    initialize_with { Contract::LocalpoolPowerTaker.new }
    forecast_kwh_pa 1000
    customer        { FactoryGirl.create(:person, :powertaker, :with_bank_account) }
    contractor      { FactoryGirl.create(:person, :with_bank_account) }
    before(:create) do |contract, _evaluator|
      unless contract.register
        meter = FactoryGirl.create(:meter, :real, :one_way, group: contract.localpool)
        contract.register = meter.registers.first
      end
    end
  end

  trait :with_tariff do
    before(:create) do |contract, _evaluator|
      contract.tariffs = [ build(:tariff) ]
    end
  end

  trait :with_payment do
    before(:create) do |contract, _evaluator|
      contract.payments = [ build(:payment) ]
    end
  end
end