FactoryGirl.define do
  factory :organization, class: 'Organization::General' do
    name             { generate(:organization_name) }
    slug             { Buzzn::Slug.new(name).to_s }
    description      'Description of the generic organization'
    email            'dev+generic-organization@buzzn.net'
    phone            '089 / 32 16 8'
    website          'www.generic-organization.com'

    trait :with_contact do
      contact { FactoryGirl.create(:person, :organization_contact) }
    end

    trait :with_bank_account do
      after(:build) do |organization, _evaluator|
        organization.bank_accounts << FactoryGirl.build(:bank_account, owner: organization)
      end
    end

    trait :with_address do
      address
    end

    trait :with_legal_representation do
      legal_representation { FactoryGirl.create(:person, :organization_contact) }
    end

    trait :market do
      initialize_with { Organization::Market.new }
    end

    trait :transmission_system_operator do
      initialize_with { Organization::Market.new }
      # TODO setup market_function
      with_address
    end

    trait :distribution_system_operator do
      initialize_with { Organization::Market.new }
      # TODO setup market_function
      with_address
    end

    trait :electricity_supplier do
      initialize_with { Organization::Market.new }
      with_address
      after(:create) do |orga|
        FactoryGirl.create(:organization_market_function, function: :electricity_supplier, organization: orga)
      end
    end

    trait :metering_service_provider do
      initialize_with { Organization::Market.new }
      # TODO setup market_function
      with_address
    end

    trait :metering_point_operator do
      initialize_with { Organization::Market.new }
      # TODO setup market_function
      with_address
    end

    trait :with_legal_representation do
      legal_representation { FactoryGirl.build(:person, :organization_legal_representative) }
    end
  end
end
