FactoryGirl.define do
  factory :contract, class: 'Contract::MeteringPointOperator' do
    transient do
      customer nil
      contractor nil
    end
    localpool                     { FactoryGirl.build(:localpool) }
    contract_number               { generate(:metering_point_operator_contract_nr) }
    signing_date                  Date.parse("2015-10-11")
    begin_date                    Date.parse("2016-01-01")
    contract_number_addition      1
    power_of_attorney             true
    metering_point_operator_name  "Generic metering point operator"

    after(:build) do |account, transients|
      unless account.is_a?(Contract::LocalpoolThirdParty)
        # assign customer if not present yet
        account.customer = transients.customer || FactoryGirl.create(:person, :with_bank_account)
        # assign contractor if not present yet
        account.contractor = transients.contractor || FactoryGirl.create(:organization, :with_bank_account)
      end
    end

    before(:create) do |contract, _evaluator|
      unless contract.is_a?(Contract::LocalpoolThirdParty)
        %i(customer contractor).each do |identifier|
          bank_account = contract.send(identifier).bank_accounts.first
          contract.send("#{identifier}_bank_account=", bank_account) if bank_account.present?
        end
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
    before(:create) do |contract, _evaluator|
      contract.tax_data = FactoryGirl.build(:tax_data)
    end
  end

  trait :localpool_powertaker do
    contract_number { generate(:localpool_power_taker_contract_nr) }
    initialize_with { Contract::LocalpoolPowerTaker.new }
    forecast_kwh_pa 1000
    customer        { FactoryGirl.create(:person, :powertaker, :with_bank_account) }
    #contractor      { FactoryGirl.create(:person, :with_bank_account) }
    before(:create) do |contract, _evaluator|
      contract.contractor = contract.localpool.owner
      unless contract.register
        meter = FactoryGirl.create(:meter, :real, :one_way, group: contract.localpool)
        contract.register = meter.registers.first
      end
    end
  end

  trait :localpool_third_party do
    contract_number { generate(:localpool_power_taker_contract_nr) }
    initialize_with { Contract::LocalpoolThirdParty.new }
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
