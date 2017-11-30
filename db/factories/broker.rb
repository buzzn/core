FactoryGirl.define do
  factory :broker, class: 'Broker::Base' do
    # FIXME: the resource association currently always contains a Meter::Real, so we should name it like that.
    meter              { FactoryGirl.create(:meter, :real) }
    type               "Broker::Base"

    trait :discovergy do
      initialize_with { Broker::Discovergy.new }
      type            "Broker::Discovergy"
    end
  end
end
