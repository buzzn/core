FactoryGirl.define do
  factory :broker, class: 'Broker::Base' do
    provider_login     "login"
    provider_password  "123456789"
    # This sucks. resource is currently always Meter::Real, so we should name it accordingly.
    resource           { FactoryGirl.build(:meter, :real) }
    type               "Broker::Base"

    before(:create) do |broker, _evaluator|
      broker.mode = broker.resource.registers.first.is_a?(Register::Input) ? :in : :out
    end

    trait :discovergy do
      initialize_with { Broker::Discovergy.new }
      type            "Broker::Discovergy"
      external_id     "discovergy-001"
      consumer_key    "some-consumer-key"
      consumer_secret "some-consumer-secret"
    end
  end
end
