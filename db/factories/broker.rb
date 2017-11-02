FactoryGirl.define do
  factory :broker, class: 'Broker::Base' do
    provider_login     "login"
    provider_password  "123456789"
    resource           { FactoryGirl.create(:meter_real) }
    mode               :out
    type               "Broker::Base"

    trait :discovergy do
      initialize_with { Broker::Discovergy.new } # a slight hack to define a trait of broker, but use a different subclass
      type            "Broker::Discovergy"
      external_id     "discovergy-001"
      consumer_key    "some-consumer-key"
      consumer_secret "some-consumer-secret"
    end
  end
end
