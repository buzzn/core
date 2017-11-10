FactoryGirl.define do
  factory :localpool, class: 'Group::Localpool' do

    transient do
      admins []
      prices_attrs []
    end

    name        { generate(:localpool_name) }
    description { |attrs| "#{attrs[:name]} description" }
    owner       { FactoryGirl.create(:person) }
    address
    start_date  { Date.parse("2016-01-01") }

    trait :people_power do
      name "People Power Group"
      description "Power to the people!"
      # FIXME resurrect this once we have it used by the application
      #website "www.peoplepower.de"
    end

    after(:create) do |group, evaluator|
      group.owner.add_role(Role::GROUP_OWNER, group)
      evaluator.admins.each { |admin| admin.add_role(Role::GROUP_ADMIN, group) }
      evaluator.prices_attrs.each { |price_attrs| build(:price, price_attrs.merge(localpool: group)) }
    end
  end
end
