FactoryGirl.define do
  factory :contract, class: 'Contract::LocalpoolProcessing' do
    transient do
      customer nil
      contractor nil
    end
    localpool                     { FactoryGirl.build(:group, :localpool) }
    signing_date                  { (begin_date || Date.today) - 3.weeks }
    begin_date                    { localpool.start_date + 23.days }
    termination_date              { end_date.present? ? end_date - 3.months : nil }
    power_of_attorney             true

    after(:build) do |account, transients|
      case account
      when Contract::LocalpoolThirdParty
        nil
      when Contract::MeteringPointOperator
        account.customer = transients.customer || transients.localpool.owner
        account.contractor = transients.contractor
      else
        # assign customer if not present yet
        account.customer = transients.customer || FactoryGirl.create(:person, :with_bank_account)
        # assign contractor if not present yet
        account.contractor = transients.contractor || FactoryGirl.create(:organization, :with_bank_account)
      end
    end

    before(:create) do |contract, _evaluator|
      unless contract.is_a?(Contract::LocalpoolThirdParty)
        %i(customer contractor).each do |identifier|
          entity = contract.send(identifier)
          next if entity.is_a?(Organization::Market)
          bank_account = entity.bank_accounts.first
          contract.send("#{identifier}_bank_account=", bank_account) if bank_account.present?
        end
      end
    end
  end

  trait :metering_point_operator do
    initialize_with { Contract::MeteringPointOperator.new }
    contractor { Organization::Market.buzzn }
    metering_point_operator_name 'Generic metering point operator'

    before(:create) do |contract, evaluator|
      contract.customer = evaluator.customer ? evaluator.customer : contract.localpool.owner
    end

    after(:build) do |account, transients|
      FactoryGirl.create(:bank_account, owner: account.customer)
    end
  end

  trait :power_taker do
    contract_number { generate(:power_taker_contract_nr) }
  end

  trait :power_giver do
    contract_number { generate(:power_giver_contract_nr) }
  end

  trait :localpool_processing do
    initialize_with { Contract::LocalpoolProcessing.new }
    contractor { Organization::Market.buzzn }
    before(:create) do |contract, evaluator|
      contract.customer = evaluator.customer ? evaluator.customer : contract.localpool.owner
      contract.tax_data = FactoryGirl.build(:tax_data)
    end
  end

  trait :is_localpool_powertaker_contract do

    register_meta_option { FactoryGirl.create(:meta_option, :public) }

    before(:create) do |contract, _evaluator|
      unless contract.register_meta
        meter = FactoryGirl.create(:meter, :real, :one_way,
                                   group: contract.localpool)
        contract.register_meta = meter.registers.first.meta
      end
      unless contract.localpool.localpool_processing_contracts.any?
        FactoryGirl.create(:contract, :localpool_processing, localpool: contract.localpool)
      end
    end
  end

  trait :localpool_powertaker do
    is_localpool_powertaker_contract
    initialize_with { Contract::LocalpoolPowerTaker.new }
    forecast_kwh_pa 1000
    customer        { FactoryGirl.create(:person, :powertaker, :with_bank_account) }
    before(:create) do |contract, _evaluator|
      contract.contractor = contract.localpool.owner
    end
  end

  trait :localpool_third_party do
    is_localpool_powertaker_contract
    initialize_with { Contract::LocalpoolThirdParty.new }
  end

  trait :localpool_gap do
    is_localpool_powertaker_contract
    initialize_with { Contract::LocalpoolGap.new }
  end

  trait :with_tariff do
    before(:create) do |contract, _evaluator|
      contract.tariffs = [build(:tariff, group: contract.localpool)]
    end
  end

  trait :with_payment do
    before(:create) do |contract, _evaluator|
      contract.payments = [build(:payment)]
    end
  end

  trait :with_pdf do
    after(:create) do |contract, _evaluator|
      # using Transactions::Admin::Contract::Document.call(resource: res, params: {})
      # is not trivial due to security_context
      generator = contract.pdf_generator.new(contract)
      doc = generator.create_pdf_document.document
      contract.documents << doc
    end
  end
end
